<#
.SYNOPSIS
    Manage the state of a conditional forwarder.
.DESCRIPTION
    xDnsServerConditionalForwarder can be used to manage the state of a single conditional forwarder.
.PARAMETER Ensure
    Ensure whether the zone is absent or present.
.PARAMETER Name
    The name of the zone to manage.
.PARAMETER MasterServers
    The IP addresses the forwarder should use. Mandatory if Ensure is present.
.PARAMETER ReplicationScope
    Whether the conditional forwarder should be replicated in AD, and the scope of that replication.

    Valid values are:

        * None: (file based / not replicated)
        * Custom: A user defined directory partition. DirectoryPartitionName is mandatory if Custom is set.
        * Domain: DomainDnsZones
        * Forest: ForestDnsZones
        * Legacy: The domain partition (defaultNamingContext).

.PARAMETER DirectoryPartitionName
    The name of the directory partition to use when the ReplicationScope is Custom. This value is ignored for all other replication scopes.
.PARAMETER ComputerName
    Allows use of this resource on a remote sytstem.
.PARAMETER Credential
    Credentials to use when managing configuration on a remote system.
#>

function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([Hashtable])]
    param
    (
        [Parameter()]
        [ValidateSet('Absent', 'Present')]
        [String]
        $Ensure = 'Present',

        [Parameter(Mandatory = $true)]
        [String]
        $Name,

        [Parameter()]
        [String[]]
        $MasterServers,

        [Parameter()]
        [ValidateSet('None', 'Custom', 'Domain', 'Forest', 'Legacy')]
        [String]
        $ReplicationScope = 'None',

        [Parameter()]
        [String]
        $DirectoryPartitionName,

        [Parameter()]
        [String]
        $ComputerName,

        [Parameter()]
        [PSCredential]
        $Credential
    )

    ValidateRequest

    $targetResource = @{
        Ensure                 = $Ensure
        Name                   = $Name
        MasterServers          = $null
        ReplicationScope       = $null
        DirectoryPartitionName = $null
        ZoneType               = $null
        ComputerName           = $ComputerName
    }

    $cimParams = NewCimSessionParameter @psboundparameters
    $zone = Get-DnsServerZone -Name $Name @cimParams -ErrorAction SilentlyContinue
    if ($zone)
    {
        Write-Verbose ($localizedData.FoundZone -f @(
            $zone.ZoneType
            $Name
        ))

        $targetResource.ZoneType = $zone.ZoneType
    }
    if ($zone -and $zone.ZoneType -eq 'Forwarder')
    {
        $targetResource.Ensure = 'Present'
        $targetResource.MasterServers = $zone.MasterServers

        if ($zone.IsDsIntegrated)
        {
            $targetResource.ReplicationScope = $zone.ReplicationScope
            $targetResource.DirectoryPartitionName = $zone.DirectoryPartitionName
        }
        else
        {
            $targetResource.ReplicationScope = 'None'
        }
    }
    else
    {
        Write-Verbose ($localizedData.CouldNotFindZone -f $Name)

        $targetResource.Ensure = 'Absent'
    }

    $targetResource
}

function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [ValidateSet('Absent', 'Present')]
        [String]
        $Ensure = 'Present',

        [Parameter(Mandatory = $true)]
        [String]
        $Name,

        [Parameter()]
        [String[]]
        $MasterServers,

        [Parameter()]
        [ValidateSet('None', 'Custom', 'Domain', 'Forest', 'Legacy')]
        [String]
        $ReplicationScope = 'None',

        [Parameter()]
        [String]
        $DirectoryPartitionName,

        [Parameter()]
        [String]
        $ComputerName,

        [Parameter()]
        [PSCredential]
        $Credential
    )

    ValidateRequest

    $cimParams = NewCimSessionParameter @psboundparameters
    $zone = Get-DnsServerZone -Name $Name @cimParams -ErrorAction SilentlyContinue
    if ($Ensure -eq 'Present')
    {
        $params = @{
            Name          = $Name
            MasterServers = $MasterServers
        }

        if ($zone)
        {
            # File <--> DsIntegrated requires create and destroy
            if ($zone.ZoneType -ne 'Forwarder' -or
                ($zone.IsDsIntegrated -and $ReplicationScope -eq 'None') -or
                (-not $zone.IsDsIntegrated -and $ReplicationScope -ne 'None'))
            {
                Remove-DnsServerZone -Name $Name @cimParams

                Write-Verbose ($localizedData.RecreateZone -f @(
                    $zone.ZoneType
                    $Name
                ))

                $zone = $null
            }
            else
            {
                if ("$($zone.MasterServers)" -ne "$MasterServers")
                {
                    Write-Verbose ($localizedData.UpdatingMasterServers -f @(
                        $Name
                        ($MasterServers -join ', ')
                    ))

                    $null = Set-DnsServerConditionalForwarderZone @params @cimParams
                }
            }
        }

        $params = @{
            Name = $Name
        }
        if ($ReplicationScope -ne 'None')
        {
            $params.ReplicationScope = $ReplicationScope
        }
        if ($ReplicationScope -eq 'Custom' -and
            $DirectoryPartitionName -and
            $zone.DirectoryPartitionName -ne $DirectoryPartitionName)
        {
            $params.ReplicationScope = 'Custom'
            $params.DirectoryPartitionName = $DirectoryPartitionName
        }

        if ($zone)
        {
            if (($params.ReplicationScope -and $params.ReplicationScope -ne $zone.ReplicationScope) -or $params.DirectoryPartitionName)
            {
                Write-Verbose ($localizedData.MoveADZone -f @(
                    $Name
                    $ReplicationScope
                ))

                $null = Set-DnsServerConditionalForwarderZone @params @cimParams
            }
        }
        else
        {
            Write-Verbose ($localizedData.NewZone -f $Name)

            $params.MasterServers = $MasterServers
            $null = Add-DnsServerConditionalForwarderZone @params @cimParams
        }
    }
    elseif ($Ensure -eq 'Absent')
    {
        if ($zone -and $zone.ZoneType -eq 'Forwarder')
        {
            Write-Verbose ($localizedData.RemoveZone -f $Name)

            Remove-DnsServerZone -Name $Name @cimParams
        }
    }
}

function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([Boolean])]
    param
    (
        [Parameter()]
        [ValidateSet('Absent', 'Present')]
        [String]
        $Ensure = 'Present',

        [Parameter(Mandatory = $true)]
        [String]
        $Name,

        [Parameter()]
        [String[]]
        $MasterServers,

        [Parameter()]
        [ValidateSet('None', 'Custom', 'Domain', 'Forest', 'Legacy')]
        [String]
        $ReplicationScope = 'None',

        [Parameter()]
        [String]
        $DirectoryPartitionName,

        [Parameter()]
        [String]
        $ComputerName,

        [Parameter()]
        [PSCredential]
        $Credential
    )

    ValidateRequest

    $cimParams = NewCimSessionParameter @psboundparameters
    $zone = Get-DnsServerZone -Name $Name @cimParams -ErrorAction SilentlyContinue
    if ($Ensure -eq 'Present')
    {
        if (-not $zone)
        {
            Write-Verbose ($localizedData.ZoneDoesNotExist -f $Name)

            return $false
        }

        if ($zone.ZoneType -ne 'Forwarder')
        {
            Write-Verbose ($localizedData.IncorrectZoneType -f @(
                $Name
                $zone.ZoneType
            ))

            return $false
        }

        if ($zone.IsDsIntegrated -and $ReplicationScope -eq 'None')
        {
            Write-Verbose ($localizedData.ZoneIsDsIntegrated -f $Name)

            return $false
        }

        if (-not $zone.IsDsIntegrated -and $ReplicationScope -ne 'None')
        {
            Write-Verbose ($localizedData.ZoneIsFileBased -f $Name)

            return $false
        }

        if ($ReplicationScope -ne 'None' -and $zone.ReplicationScope -ne $ReplicationScope)
        {
            Write-Verbose ($localizedData.ReplicationScopeDoesNotMatch -f @(
                $Name
                $zone.ReplicationScope
                $ReplicationScope
            ))

            return $false
        }

        if ($ReplicationScope -eq 'Custom' -and $zone.DirectoryPartitionName -ne $DirectoryPartitionName)
        {
            Write-Verbose ($localizedData.DirectoryPartitionDoesNotMatch -f @(
                $Name
                $DirectoryPartitionName
            ))

            return $false
        }

        if ("$($zone.MasterServers)" -ne "$MasterServers")
        {
            Write-Verbose ($localizedData.MasterServersDoNotMatch -f @(
                $Name
                ($MasterServers -join ', ')
                ($zone.MasterServers -join ', ')
            ))

            return $false
        }
    }
    elseif ($Ensure -eq 'Absent')
    {
        if ($zone -and $zone.ZoneType -eq 'Forwarder')
        {
            Write-Verbose ($localizedData.ZoneExists -f $Name)

            return $false
        }
    }

    return $true
}

function ValidateRequest
{
    <#
    .SYNOPSIS
        Validates the parameter combinations required by this resource.
    .DESCRIPTION
        Validates the parameter combinations required by this resource.
    #>

    [CmdletBinding()]
    param ()

    $invocationInfo = Get-Variable MyInvocation -Scope 1 -ValueOnly

    if (-not $invocationInfo.BoundParameters.ContainsKey('Ensure') -or $invocationInfo.BoundParameters['Ensure'] -eq 'Present')
    {
        if ($null -eq $invocationInfo.BoundParameters['MasterServers'] -or $invocationInfo.BoundParameters['MasterServers'].Count -eq 0)
        {
            $pscmdlet.ThrowTerminatingError((
                New-Object System.Management.Automation.ErrorRecord(
                    (New-Object System.ArgumentException($localizedData.MasterServersIsMandatory)),
                    'MasterServersIsMandatory',
                    'InvalidArgument',
                    $null
                )
            ))
        }

        if ($invocationInfo.BoundParameters['ReplicationScope'] -eq 'Custom' -and -not $invocationInfo.BoundParameters['DirectoryPartitionName'])
        {
            $pscmdlet.ThrowTerminatingError((
                New-Object System.Management.Automation.ErrorRecord(
                    (New-Object System.ArgumentException($localizedData.DirectoryPartitionNameIsMandatory)),
                    'DirectoryPartitionNameIsMandatory',
                    'InvalidArgument',
                    $null
                )
            ))
        }
    }
}

function NewCimSessionParameter
{
    <#
    .SYNOPSIS
        CimSession helper.
    .DESCRIPTION
        Generates a hashtable containing a CimSession when ComputerName and Credential are supplied.
    #>

    [CmdletBinding()]
    [OutputType([Hashtable])]
    param
    (
        [Parameter()]
        [String]
        $ComputerName,

        [Parameter()]
        [PSCredential]
        $Credential,

        [Parameter(ValueFromRemainingArguments)]
        $Ignore
    )

    $cimSession = @{}
    if ($ComputerName)
    {
        $cimSession.ComputerName = $ComputerName
    }
    if ($Credential)
    {
        $cimSession.Credential = $Credential
    }
    if ($cimSession.Count -gt 0)
    {
        @{
            CimSession = New-CimSession @params
        }
    }
    else
    {
        @{}
    }
}

Import-LocalizedData -FileName MSFT_xDnsServerConditionalForwarder -BindingVariable localizedData -ErrorAction SilentlyContinue