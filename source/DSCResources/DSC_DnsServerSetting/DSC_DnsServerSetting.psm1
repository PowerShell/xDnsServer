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
        [uint32]
        $AddressAnswerLimit,

        [Parameter()]
        [uint32]
        $AllowUpdate,

        [Parameter()]
        [bool]
        $AutoCacheUpdate,

        [Parameter()]
        [uint32]
        $AutoConfigFileZones,

        [Parameter()]
        [bool]
        $BindSecondaries,

        [Parameter()]
        [uint32]
        $BootMethod,

        [Parameter()]
        [bool]
        $DisableAutoReverseZone,

        [Parameter()]
        [bool]
        $EnableDirectoryPartitions,

        [Parameter()]
        [uint32]
        $EnableDnsSec,

        [Parameter()]
        [uint32]
        $ForwardDelegations,

        [Parameter()]
        [string[]]
        $ListeningIPAddress,

        [Parameter()]
        [bool]
        $LocalNetPriority,

        [Parameter()]
        [bool]
        $LooseWildcarding,

        [Parameter()]
        [uint32]
        $NameCheckFlag,

        [Parameter()]
        [bool]
        $RoundRobin,

        [Parameter()]
        [int16]
        $RpcProtocol,

        [Parameter()]
        [uint32]
        $SendPort,

        [Parameter()]
        [bool]
        $StrictFileParsing,

        [Parameter()]
        [uint32]
        $UpdateOptions,

        [Parameter()]
        [bool]
        $WriteAuthorityNS,

        [Parameter()]
        [uint32]
        $XfrConnectTimeout
    )

    Assert-Module -ModuleName 'DnsServer'

    $PSBoundParameters.Remove('DnsServer')

    $dnsProperties = Remove-CommonParameter -Hashtable $PSBoundParameters

    $getDnServerSettingResult = Get-DnsServerSetting -All

    $propertiesInDesiredState = @()

    foreach ($property in $dnsProperties.keys)
    {
        if ($dnsProperties.$property -ne $getDnServerSettingResult.$property)
        {
            # Property not in desired state.

            Write-Verbose -Message ($script:localizedData.SetDnsServerSetting -f $property, $dnsProperties[$property])
        }
        else
        {
            # Property in desired state.

            Write-Verbose -Message ($script:localizedData.PropertyInDesiredState -f $property)

            $propertiesInDesiredState += $property
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
    [OutputType([bool])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $DnsServer,

        [Parameter()]
        [uint32]
        $AddressAnswerLimit,

        [Parameter()]
        [uint32]
        $AllowUpdate,

        [Parameter()]
        [bool]
        $AutoCacheUpdate,

        [Parameter()]
        [uint32]
        $AutoConfigFileZones,

        [Parameter()]
        [bool]
        $BindSecondaries,

        [Parameter()]
        [uint32]
        $BootMethod,

        [Parameter()]
        [bool]
        $DisableAutoReverseZone,

        [Parameter()]
        [bool]
        $EnableDirectoryPartitions,

        [Parameter()]
        [uint32]
        $EnableDnsSec,

        [Parameter()]
        [uint32]
        $ForwardDelegations,

        [Parameter()]
        [string[]]
        $ListeningIPAddress,

        [Parameter()]
        [bool]
        $LocalNetPriority,

        [Parameter()]
        [bool]
        $LooseWildcarding,

        [Parameter()]
        [uint32]
        $NameCheckFlag,

        [Parameter()]
        [bool]
        $RoundRobin,

        [Parameter()]
        [int16]
        $RpcProtocol,

        [Parameter()]
        [uint32]
        $SendPort,

        [Parameter()]
        [bool]
        $StrictFileParsing,

        [Parameter()]
        [uint32]
        $UpdateOptions,

        [Parameter()]
        [bool]
        $WriteAuthorityNS,

        [Parameter()]
        [uint32]
        $XfrConnectTimeout
    )

    Write-Verbose -Message 'Evaluating the DNS server settings.'

    $currentState = Get-TargetResource -DnsServer $DnsServer

    $null = $PSBoundParameters.Remove('DnsServer')

    $result = Test-DscDnsParameterState -CurrentValues $currentState -DesiredValues $PSBoundParameters -Verbose:$VerbosePreference

    return $result
}
