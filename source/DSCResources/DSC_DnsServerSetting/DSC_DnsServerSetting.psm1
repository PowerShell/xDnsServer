$script:dscResourceCommonPath = Join-Path -Path $PSScriptRoot -ChildPath '..\..\Modules\DscResource.Common'
$script:dnsServerDscCommonPath = Join-Path -Path $PSScriptRoot -ChildPath '..\..\Modules\DnsServerDsc.Common'

Import-Module -Name $script:dscResourceCommonPath
Import-Module -Name $script:dnsServerDscCommonPath

$script:localizedData = Get-LocalizedData -DefaultUICulture 'en-US'

$properties = 'LocalNetPriority', 'AutoConfigFileZones', 'AddressAnswerLimit', 'UpdateOptions', 'DisableAutoReverseZone', 'StrictFileParsing', 'DisjointNets', 'EnableDirectoryPartitions', 'XfrConnectTimeout', 'AllowUpdate', 'DsAvailable', 'BootMethod', 'LooseWildcarding', 'DsPollingInterval', 'BindSecondaries', 'LogLevel', 'AutoCacheUpdate', 'EnableDnsSec', 'NameCheckFlag', 'SendPort', 'WriteAuthorityNS', 'IsSlave', 'ListenAddresses', 'DsTombstoneInterval', 'RpcProtocol', 'RoundRobin', 'ForwardDelegations'

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

    foreach ($property in $properties)
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
        Values between 5 and 28 are valid.

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

    .PARAMETER DisjointNets
        Indicates whether the default port binding for a socket used to send queries
        to remote DNS Servers can be overridden.

    .PARAMETER DsPollingInterval
        Interval, in seconds, to poll the DS-integrated zones.

    .PARAMETER DsTombstoneInterval
        Lifetime of tombstoned records in Directory Service integrated zones,
        expressed in seconds.

    .PARAMETER EnableDirectoryPartitions
        Specifies whether support for application directory partitions is enabled on
        the DNS Server.

    .PARAMETER EnableDnsSec
        Specifies whether the DNS Server includes DNSSEC-specific RRs, KEY, SIG, and
        NXT in a response.

    .PARAMETER ForwardDelegations
        Specifies whether queries to delegated sub-zones are forwarded.

    .PARAMETER IsSlave
        TRUE if the DNS server does not use recursion when name-resolution through
        forwarders fails.

    .PARAMETER ListeningIPAddress
        Enumerates the list of IP addresses on which the DNS Server can receive
        queries.

    .PARAMETER LocalNetPriority
        Indicates whether the DNS Server gives priority to the local net address
        when returning A records.

    .PARAMETER LogLevel
        Indicates which policies are activated in the Event Viewer system log.

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
        $DisjointNets,

        [Parameter()]
        [uint32]
        $DsPollingInterval,

        [Parameter()]
        [uint32]
        $DsTombstoneInterval,

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
        [bool]
        $IsSlave,

        [Parameter()]
        [string[]]
        $ListeningIPAddress,

        [Parameter()]
        [bool]
        $LocalNetPriority,

        [Parameter()]
        [uint32]
        $LogLevel,

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

    $dnsServerInstance = Get-CimClassMicrosoftDnsServer -DnsServer $DnsServer

    try
    {
        foreach ($property in $dnsProperties.keys)
        {
            Write-Verbose -Message ($script:localizedData.SetDnsServerSetting -f $property, $dnsProperties[$property])
        }

        $setCimInstanceParameters = @{
            InputObject   = $dnsServerInstance
            Property   = $dnsProperties
            ErrorAction = 'Stop'
        }

        if ($DnsServer -ne 'localhost')
        {
            $setCimInstanceParameters['ComputerName'] = $DnsServer
        }

        Set-CimInstance @setCimInstanceParameters
    }
    catch
    {
        throw $_
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
        Values between 5 and 28 are valid.

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

    .PARAMETER DisjointNets
        Indicates whether the default port binding for a socket used to send queries
        to remote DNS Servers can be overridden.

    .PARAMETER DsPollingInterval
        Interval, in seconds, to poll the DS-integrated zones.

    .PARAMETER DsTombstoneInterval
        Lifetime of tombstoned records in Directory Service integrated zones,
        expressed in seconds.

    .PARAMETER EnableDirectoryPartitions
        Specifies whether support for application directory partitions is enabled on
        the DNS Server.

    .PARAMETER EnableDnsSec
        Specifies whether the DNS Server includes DNSSEC-specific RRs, KEY, SIG, and
        NXT in a response.

    .PARAMETER ForwardDelegations
        Specifies whether queries to delegated sub-zones are forwarded.

    .PARAMETER IsSlave
        TRUE if the DNS server does not use recursion when name-resolution through
        forwarders fails.

    .PARAMETER ListeningIPAddress
        Enumerates the list of IP addresses on which the DNS Server can receive
        queries.

    .PARAMETER LocalNetPriority
        Indicates whether the DNS Server gives priority to the local net address
        when returning A records.

    .PARAMETER LogLevel
        Indicates which policies are activated in the Event Viewer system log.

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
        $DisjointNets,

        [Parameter()]
        [uint32]
        $DsPollingInterval,

        [Parameter()]
        [uint32]
        $DsTombstoneInterval,

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
        [bool]
        $IsSlave,

        [Parameter()]
        [string[]]
        $ListeningIPAddress,

        [Parameter()]
        [bool]
        $LocalNetPriority,

        [Parameter()]
        [uint32]
        $LogLevel,

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

    $result = Test-DscDnsParameterState -CurrentValues $currentState -DesiredValues $PSBoundParameters -TurnOffTypeChecking -Verbose:$VerbosePreference

    return $result
}

function Get-CimClassMicrosoftDnsServer
{
    [CmdletBinding()]
    [OutputType([Microsoft.Management.Infrastructure.CimInstance])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $DnsServer
    )

    $getCimInstanceParameters = @{
        NameSpace   = 'root\MicrosoftDNS'
        ClassName   = 'MicrosoftDNS_Server'
        ErrorAction = 'Stop'
    }

    if ($DnsServer -ne 'localhost')
    {
        $getCimInstanceParameters['ComputerName'] = $DnsServer
    }

    $dnsServerInstance = Get-CimInstance @getCimInstanceParameters

    return $dnsServerInstance
}

Export-ModuleMember -Function *-TargetResource
