$script:dscResourceCommonPath = Join-Path -Path $PSScriptRoot -ChildPath '..\..\Modules\DscResource.Common'
$script:dnsServerDscCommonPath = Join-Path -Path $PSScriptRoot -ChildPath '..\..\Modules\DnsServerDsc.Common'

Import-Module -Name $script:dscResourceCommonPath
Import-Module -Name $script:dnsServerDscCommonPath

$script:localizedData = Get-LocalizedData -DefaultUICulture 'en-US'

$script:classProperties = @(
    'LocalNetPriority'
    'AutoConfigFileZones'
    'AddressAnswerLimit'
    'UpdateOptions'
    'DisableAutoReverseZone'
    'StrictFileParsing'
    'EnableDirectoryPartitions'
    'XfrConnectTimeout'
    'AllowUpdate'
    'BootMethod'
    'LooseWildcarding'
    'BindSecondaries'
    'AutoCacheUpdate'
    'EnableDnsSec'
    'NameCheckFlag'
    'SendPort'
    'WriteAuthorityNS'
    'ListeningIPAddress'
    'RpcProtocol'
    'RoundRobin'
    'ForwardDelegations'

    # Read-only properties
    'DsAvailable'
    'MajorVersion'
    'MinorVersion'
    'BuildNumber'
    'IsReadOnlyDC'
    'AllIPAddress'
    'ForestDirectoryPartitionBaseName'
    'DomainDirectoryPartitionBaseName'
    'MaximumUdpPacketSize'
)

<#
    .SYNOPSIS
        Returns the current state of the DNS server settings.

    .PARAMETER DnsServer
        Specifies the DNS server to connect to, or use 'localhost' for the current
        node.
#>
function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $DnsServer
    )

    Assert-Module -ModuleName 'DnsServer'

    Write-Verbose ($script:localizedData.GettingDnsServerSettings)

    $getDnsServerSettingParameters = @{
        All = $true
    }

    if ($DnsServer -ne 'localhost')
    {
        $getDnsServerSettingParameters['ComputerName'] = $DnsServer
    }

    $dnsServerInstance = Get-DnsServerSetting @getDnsServerSettingParameters

    $returnValue = @{}

    foreach ($property in $script:classProperties)
    {
        $returnValue.Add($property, $dnsServerInstance."$property")
    }

    $returnValue.DnsServer = $DnsServer

    return $returnValue
}

<#
    .SYNOPSIS
        Set the desired state of the DNS server settings.

    .PARAMETER DnsServer
        Specifies the DNS server to connect to, or use 'localhost' for the current
        node.

    .PARAMETER AddressAnswerLimit
        Maximum number of host records returned in response to an address request.
        Values between 5 and 28, or 0 are valid.

    .PARAMETER AllowUpdate
        Specifies whether the DNS Server accepts dynamic update requests.

    .PARAMETER AutoCacheUpdate
        Indicates whether the DNS Server attempts to update its cache entries using
        data from root servers.

    .PARAMETER AutoConfigFileZones
        Indicates which standard primary zones that are authoritative for the name of
        the DNS Server must be updated when the name server changes.

    .PARAMETER BindSecondaries
        Determines the AXFR message format when sending to non-Microsoft DNS Server
        secondaries.

    .PARAMETER BootMethod
        Initialization method for the DNS Server.

    .PARAMETER DisableAutoReverseZone
        Indicates whether the DNS Server automatically creates standard reverse look
        up zones.

    .PARAMETER EnableDirectoryPartitions
        Specifies whether support for application directory partitions is enabled on
        the DNS Server.

    .PARAMETER EnableDnsSec
        Specifies whether the DNS Server includes DNSSEC-specific RRs, KEY, SIG, and
        NXT in a response.

    .PARAMETER ForwardDelegations
        Specifies whether queries to delegated sub-zones are forwarded.

    .PARAMETER ListeningIPAddress
        Enumerates the list of IP addresses on which the DNS Server can receive
        queries.

    .PARAMETER LocalNetPriority
        Indicates whether the DNS Server gives priority to the local net address
        when returning A records.

    .PARAMETER LooseWildcarding
        Indicates whether the DNS Server performs loose wildcarding.

    .PARAMETER NameCheckFlag
        Indicates the set of eligible characters to be used in DNS names.

    .PARAMETER RoundRobin
        Indicates whether the DNS Server round robins multiple A records.

    .PARAMETER RpcProtocol
        RPC protocol or protocols over which administrative RPC runs.

    .PARAMETER SendPort
        Port on which the DNS Server sends UDP queries to other servers.

    .PARAMETER StrictFileParsing
        Indicates whether the DNS Server parses zone files strictly.

    .PARAMETER UpdateOptions
        Restricts the type of records that can be dynamically updated on the server,
        used in addition to the AllowUpdate settings on Server and Zone objects.

    .PARAMETER WriteAuthorityNS
        Specifies whether the DNS Server writes NS and SOA records to the authority
        section on successful response.

    .PARAMETER XfrConnectTimeout
        Time, in seconds, the DNS Server waits for a successful TCP connection to
        a remote server when attempting a zone transfer.
#>
function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $DnsServer,

        [Parameter()]
        [System.UInt32]
        $AddressAnswerLimit,

        [Parameter()]
        [System.Boolean]
        $AllowUpdate,

        [Parameter()]
        [System.Boolean]
        $AutoCacheUpdate,

        [Parameter()]
        [System.UInt32]
        $AutoConfigFileZones,

        [Parameter()]
        [System.Boolean]
        $BindSecondaries,

        [Parameter()]
        [System.UInt32]
        $BootMethod,

        [Parameter()]
        [System.Boolean]
        $DisableAutoReverseZone,

        [Parameter()]
        [System.Boolean]
        $EnableDirectoryPartitions,

        [Parameter()]
        [System.Boolean]
        $EnableDnsSec,

        [Parameter()]
        [System.Boolean]
        $ForwardDelegations,

        [Parameter()]
        [System.String[]]
        $ListeningIPAddress,

        [Parameter()]
        [System.Boolean]
        $LocalNetPriority,

        [Parameter()]
        [System.Boolean]
        $LooseWildcarding,

        [Parameter()]
        [System.UInt32]
        $NameCheckFlag,

        [Parameter()]
        [System.Boolean]
        $RoundRobin,

        [Parameter()]
        [System.UInt32]
        $RpcProtocol,

        [Parameter()]
        [System.UInt32]
        $SendPort,

        [Parameter()]
        [System.Boolean]
        $StrictFileParsing,

        [Parameter()]
        [System.UInt32]
        $UpdateOptions,

        [Parameter()]
        [System.Boolean]
        $WriteAuthorityNS,

        [Parameter()]
        [System.UInt32]
        $XfrConnectTimeout
    )

    Assert-Module -ModuleName 'DnsServer'

    $PSBoundParameters.Remove('DnsServer')

    $dnsProperties = Remove-CommonParameter -Hashtable $PSBoundParameters

    $getDnServerSettingResult = Get-DnsServerSetting -All

    $propertiesInDesiredState = @()

    foreach ($property in $dnsProperties.keys)
    {
        if ($property -eq 'ListeningIPAddress')
        {
            # Compare array

            $compareObjectParameters = @{
                ReferenceObject = $dnsProperties.$property
                DifferenceObject = $getDnServerSettingResult.$property
            }

            $isPropertyInDesiredState = -not (Compare-Object @compareObjectParameters)
        }
        else
        {
            $isPropertyInDesiredState = $dnsProperties.$property -eq $getDnServerSettingResult.$property
        }

        if ($isPropertyInDesiredState)
        {
            # Property in desired state.

            Write-Verbose -Message ($script:localizedData.PropertyInDesiredState -f $property)

            $propertiesInDesiredState += $property

        }
        else
        {
            # Property not in desired state.

            Write-Verbose -Message ($script:localizedData.SetDnsServerSetting -f $property, $dnsProperties[$property])
        }
    }

    # Remove passed parameters that are in desired state.
    $propertiesInDesiredState | ForEach-Object -Process {
        $dnsProperties.Remove($_)
    }

    if ($dnsProperties.Keys.Count -eq 0)
    {
        Write-Verbose -Message $script:localizedData.SettingsInDesiredState
    }
    else
    {
        # Set all desired values for the properties that were not in desired state.
        $dnsProperties.Keys | ForEach-Object -Process {
            $getDnServerSettingResult.$_ = $dnsProperties.$_
        }

        $setDnServerSettingParameters = @{
            ErrorAction = 'Stop'
        }

        if ($DnsServer -ne 'localhost')
        {
            $setDnServerSettingParameters['ComputerName'] = $DnsServer
        }

        $getDnServerSettingResult | Set-DnsServerSetting @setDnServerSettingParameters
    }
}

<#
    .SYNOPSIS
        Tests the desired state of the DNS server settings.

    .PARAMETER DnsServer
        Specifies the DNS server to connect to, or use 'localhost' for the current
        node.

    .PARAMETER AddressAnswerLimit
        Maximum number of host records returned in response to an address request.
        Values between 5 and 28, or 0 are valid.

    .PARAMETER AllowUpdate
        Specifies whether the DNS Server accepts dynamic update requests.

    .PARAMETER AutoCacheUpdate
        Indicates whether the DNS Server attempts to update its cache entries using
        data from root servers.

    .PARAMETER AutoConfigFileZones
        Indicates which standard primary zones that are authoritative for the name of
        the DNS Server must be updated when the name server changes.

    .PARAMETER BindSecondaries
        Determines the AXFR message format when sending to non-Microsoft DNS Server
        secondaries.

    .PARAMETER BootMethod
        Initialization method for the DNS Server.

    .PARAMETER DisableAutoReverseZone
        Indicates whether the DNS Server automatically creates standard reverse look
        up zones.

    .PARAMETER EnableDirectoryPartitions
        Specifies whether support for application directory partitions is enabled on
        the DNS Server.

    .PARAMETER EnableDnsSec
        Specifies whether the DNS Server includes DNSSEC-specific RRs, KEY, SIG, and
        NXT in a response.

    .PARAMETER ForwardDelegations
        Specifies whether queries to delegated sub-zones are forwarded.

    .PARAMETER ListeningIPAddress
        Enumerates the list of IP addresses on which the DNS Server can receive
        queries.

    .PARAMETER LocalNetPriority
        Indicates whether the DNS Server gives priority to the local net address
        when returning A records.

    .PARAMETER LooseWildcarding
        Indicates whether the DNS Server performs loose wildcarding.

    .PARAMETER NameCheckFlag
        Indicates the set of eligible characters to be used in DNS names.

    .PARAMETER RoundRobin
        Indicates whether the DNS Server round robins multiple A records.

    .PARAMETER RpcProtocol
        RPC protocol or protocols over which administrative RPC runs.

    .PARAMETER SendPort
        Port on which the DNS Server sends UDP queries to other servers.

    .PARAMETER StrictFileParsing
        Indicates whether the DNS Server parses zone files strictly.

    .PARAMETER UpdateOptions
        Restricts the type of records that can be dynamically updated on the server,
        used in addition to the AllowUpdate settings on Server and Zone objects.

    .PARAMETER WriteAuthorityNS
        Specifies whether the DNS Server writes NS and SOA records to the authority
        section on successful response.

    .PARAMETER XfrConnectTimeout
        Time, in seconds, the DNS Server waits for a successful TCP connection to
        a remote server when attempting a zone transfer.
#>
function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $DnsServer,

        [Parameter()]
        [System.UInt32]
        $AddressAnswerLimit,

        [Parameter()]
        [System.Boolean]
        $AllowUpdate,

        [Parameter()]
        [System.Boolean]
        $AutoCacheUpdate,

        [Parameter()]
        [System.UInt32]
        $AutoConfigFileZones,

        [Parameter()]
        [System.Boolean]
        $BindSecondaries,

        [Parameter()]
        [System.UInt32]
        $BootMethod,

        [Parameter()]
        [System.Boolean]
        $DisableAutoReverseZone,

        [Parameter()]
        [System.Boolean]
        $EnableDirectoryPartitions,

        [Parameter()]
        [System.Boolean]
        $EnableDnsSec,

        [Parameter()]
        [System.Boolean]
        $ForwardDelegations,

        [Parameter()]
        [System.String[]]
        $ListeningIPAddress,

        [Parameter()]
        [System.Boolean]
        $LocalNetPriority,

        [Parameter()]
        [System.Boolean]
        $LooseWildcarding,

        [Parameter()]
        [System.UInt32]
        $NameCheckFlag,

        [Parameter()]
        [System.Boolean]
        $RoundRobin,

        [Parameter()]
        [System.UInt32]
        $RpcProtocol,

        [Parameter()]
        [System.UInt32]
        $SendPort,

        [Parameter()]
        [System.Boolean]
        $StrictFileParsing,

        [Parameter()]
        [System.UInt32]
        $UpdateOptions,

        [Parameter()]
        [System.Boolean]
        $WriteAuthorityNS,

        [Parameter()]
        [System.UInt32]
        $XfrConnectTimeout
    )

    Write-Verbose -Message 'Evaluating the DNS server settings.'

    $currentState = Get-TargetResource -DnsServer $DnsServer

    $null = $PSBoundParameters.Remove('DnsServer')

    $result = $true

    # Returns an item for each property that is not in desired state.
    if (Compare-DscParameterState -CurrentValues $currentState -DesiredValues $PSBoundParameters -Verbose:$VerbosePreference)
    {
        $result = $false
    }

    return $result
}
