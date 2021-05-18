$script:dscResourceCommonPath = Join-Path -Path $PSScriptRoot -ChildPath '..\..\Modules\DscResource.Common'
$script:dnsServerDscCommonPath = Join-Path -Path $PSScriptRoot -ChildPath '..\..\Modules\DnsServerDsc.Common'

Import-Module -Name $script:dscResourceCommonPath
Import-Module -Name $script:dnsServerDscCommonPath

$script:localizedData = Get-LocalizedData -DefaultUICulture 'en-US'

$script:timeSpanProperties = @(
    'LameDelegationTTL'
    'MaximumSignatureScanPeriod'
    'MaximumTrustAnchorActiveRefreshInterval'
    'ZoneWritebackInterval'
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

    $classProperties = @(
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
        'EnableIPv6'
        'EnableOnlineSigning'
        'EnableDuplicateQuerySuppression'
        'AllowCnameAtNs'
        'EnableRsoForRodc'
        'OpenAclOnProxyUpdates'
        'NoUpdateDelegations'
        'EnableUpdateForwarding'
        'EnableWinsR'
        'DeleteOutsideGlue'
        'AppendMsZoneTransferTag'
        'AllowReadOnlyZoneTransfer'
        'EnableSendErrorSuppression'
        'SilentlyIgnoreCnameUpdateConflicts'
        'EnableIQueryResponseGeneration'
        'AdminConfigured'
        'PublishAutoNet'
        'ReloadException'
        'IgnoreServerLevelPolicies'
        'IgnoreAllPolicies'
        'EnableVersionQuery'
        'AutoCreateDelegation'
        'RemoteIPv4RankBoost'
        'RemoteIPv6RankBoost'
        'MaximumRodcRsoQueueLength'
        'MaximumRodcRsoAttemptsPerCycle'
        'MaxResourceRecordsInNonSecureUpdate'
        'LocalNetPriorityMask'
        'TcpReceivePacketSize'
        'SelfTest'
        'XfrThrottleMultiplier'
        'SocketPoolSize'
        'QuietRecvFaultInterval'
        'QuietRecvLogInterval'
        'SyncDsZoneSerial'
        'ScopeOptionValue'
        'VirtualizationInstanceOptionValue'
        'ServerLevelPluginDll'
        'RootTrustAnchorsURL'
        'SocketPoolExcludedPortRanges'
        'LameDelegationTTL'
        'MaximumSignatureScanPeriod'
        'MaximumTrustAnchorActiveRefreshInterval'
        'ZoneWritebackInterval'

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

    $returnValue = @{}

    foreach ($property in $classProperties)
    {
        if ($property -in $script:timeSpanProperties)
        {
            $returnValue.Add($property, $dnsServerInstance.$property.ToString())
        }
        else
        {
            $returnValue.Add($property, $dnsServerInstance.$property)
        }
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

    .PARAMETER EnableIPv6
        Not written yet.

    .PARAMETER EnableOnlineSigning
        Not written yet.

    .PARAMETER EnableDuplicateQuerySuppression
        Not written yet.

    .PARAMETER AllowCnameAtNs
        Not written yet.

    .PARAMETER EnableRsoForRodc
        Not written yet.

    .PARAMETER OpenAclOnProxyUpdates
        Not written yet.

    .PARAMETER NoUpdateDelegations
        Not written yet.

    .PARAMETER EnableUpdateForwarding
        Not written yet.

    .PARAMETER EnableWinsR
        Not written yet.

    .PARAMETER DeleteOutsideGlue
        Not written yet.

    .PARAMETER AppendMsZoneTransferTag
        Not written yet.

    .PARAMETER AllowReadOnlyZoneTransfer
        Not written yet.

    .PARAMETER EnableSendErrorSuppression
        Not written yet.

    .PARAMETER SilentlyIgnoreCnameUpdateConflicts
        Not written yet.

    .PARAMETER EnableIQueryResponseGeneration
        Not written yet.

    .PARAMETER AdminConfigured
        Not written yet.

    .PARAMETER PublishAutoNet
        Not written yet.

    .PARAMETER ReloadException
        Not written yet.

    .PARAMETER IgnoreServerLevelPolicies
        Not written yet.

    .PARAMETER IgnoreAllPolicies
        Not written yet.

    .PARAMETER EnableVersionQuery
        Not written yet.

    .PARAMETER AutoCreateDelegation
        Not written yet.

    .PARAMETER RemoteIPv4RankBoost
        Not written yet.

    .PARAMETER RemoteIPv6RankBoost
        Not written yet.

    .PARAMETER MaximumRodcRsoQueueLength
        Not written yet.

    .PARAMETER MaximumRodcRsoAttemptsPerCycle
        Not written yet.

    .PARAMETER MaxResourceRecordsInNonSecureUpdate
        Not written yet.

    .PARAMETER LocalNetPriorityMask
        Not written yet.

    .PARAMETER TcpReceivePacketSize
        Not written yet.

    .PARAMETER SelfTest
        Not written yet.

    .PARAMETER XfrThrottleMultiplier
        Not written yet.

    .PARAMETER SocketPoolSize
        Not written yet.

    .PARAMETER QuietRecvFaultInterval
        Not written yet.

    .PARAMETER QuietRecvLogInterval
        Not written yet.

    .PARAMETER SyncDsZoneSerial
        Not written yet.

    .PARAMETER ScopeOptionValue
        Not written yet.

    .PARAMETER VirtualizationInstanceOptionValue
        Not written yet.

    .PARAMETER ServerLevelPluginDll
        Not written yet.

    .PARAMETER RootTrustAnchorsURL
        Not written yet.

    .PARAMETER SocketPoolExcludedPortRanges
        Not written yet.

    .PARAMETER LameDelegationTTL
        Not written yet.

    .PARAMETER MaximumSignatureScanPeriod
        Not written yet.

    .PARAMETER MaximumTrustAnchorActiveRefreshInterval
        Not written yet.

    .PARAMETER ZoneWritebackInterval
        Not written yet.
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
        $XfrConnectTimeout,

        [Parameter()]
        [System.Boolean]
        $EnableIPv6,

        [Parameter()]
        [System.Boolean]
        $EnableOnlineSigning,

        [Parameter()]
        [System.Boolean]
        $EnableDuplicateQuerySuppression,

        [Parameter()]
        [System.Boolean]
        $AllowCnameAtNs,

        [Parameter()]
        [System.Boolean]
        $EnableRsoForRodc,

        [Parameter()]
        [System.Boolean]
        $OpenAclOnProxyUpdates,

        [Parameter()]
        [System.Boolean]
        $NoUpdateDelegations,

        [Parameter()]
        [System.Boolean]
        $EnableUpdateForwarding,

        [Parameter()]
        [System.Boolean]
        $EnableWinsR,

        [Parameter()]
        [System.Boolean]
        $DeleteOutsideGlue,

        [Parameter()]
        [System.Boolean]
        $AppendMsZoneTransferTag,

        [Parameter()]
        [System.Boolean]
        $AllowReadOnlyZoneTransfer,

        [Parameter()]
        [System.Boolean]
        $EnableSendErrorSuppression,

        [Parameter()]
        [System.Boolean]
        $SilentlyIgnoreCnameUpdateConflicts,

        [Parameter()]
        [System.Boolean]
        $EnableIQueryResponseGeneration,

        [Parameter()]
        [System.Boolean]
        $AdminConfigured,

        [Parameter()]
        [System.Boolean]
        $PublishAutoNet,

        [Parameter()]
        [System.Boolean]
        $ReloadException,

        [Parameter()]
        [System.Boolean]
        $IgnoreServerLevelPolicies,

        [Parameter()]
        [System.Boolean]
        $IgnoreAllPolicies,

        [Parameter()]
        [System.UInt32]
        $EnableVersionQuery,

        [Parameter()]
        [System.UInt32]
        $AutoCreateDelegation,

        [Parameter()]
        [System.UInt32]
        $RemoteIPv4RankBoost,

        [Parameter()]
        [System.UInt32]
        $RemoteIPv6RankBoost,

        [Parameter()]
        [System.UInt32]
        $MaximumRodcRsoQueueLength,

        [Parameter()]
        [System.UInt32]
        $MaximumRodcRsoAttemptsPerCycle,

        [Parameter()]
        [System.UInt32]
        $MaxResourceRecordsInNonSecureUpdate,

        [Parameter()]
        [System.UInt32]
        $LocalNetPriorityMask,

        [Parameter()]
        [System.UInt32]
        $TcpReceivePacketSize,

        [Parameter()]
        [System.UInt32]
        $SelfTest,

        [Parameter()]
        [System.UInt32]
        $XfrThrottleMultiplier,

        [Parameter()]
        [System.UInt32]
        $SocketPoolSize,

        [Parameter()]
        [System.UInt32]
        $QuietRecvFaultInterval,

        [Parameter()]
        [System.UInt32]
        $QuietRecvLogInterval,

        [Parameter()]
        [System.UInt32]
        $SyncDsZoneSerial,

        [Parameter()]
        [System.UInt32]
        $ScopeOptionValue,

        [Parameter()]
        [System.UInt32]
        $VirtualizationInstanceOptionValue,

        [Parameter()]
        [System.String]
        $ServerLevelPluginDll,

        [Parameter()]
        [System.String]
        $RootTrustAnchorsURL,

        [Parameter()]
        [System.String[]]
        $SocketPoolExcludedPortRanges,

        [Parameter()]
        [System.String]
        $LameDelegationTTL,

        [Parameter()]
        [System.String]
        $MaximumSignatureScanPeriod,

        [Parameter()]
        [System.String]
        $MaximumTrustAnchorActiveRefreshInterval,

        [Parameter()]
        [System.String]
        $ZoneWritebackInterval
    )

    Assert-Module -ModuleName 'DnsServer'

    $PSBoundParameters.Remove('DnsServer')

    $dnsProperties = Remove-CommonParameter -Hashtable $PSBoundParameters

    $getDnServerSettingResult = Get-DnsServerSetting -All

    $propertiesInDesiredState = @()

    foreach ($property in $dnsProperties.keys)
    {
        if ($property -in ('ListeningIPAddress', 'SocketPoolExcludedPortRanges'))
        {
            # Compare array

            $compareObjectParameters = @{
                ReferenceObject  = $dnsProperties.$property
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
            $property = $_

            if ($property -in $script:timeSpanProperties)
            {
                $timeSpan = New-TimeSpan

                <#
                    When this resource is converted to a class-based resource this should
                    be replaced by private function ConvertTo-TimeSpan.
                #>
                if (-not [System.TimeSpan]::TryParse($dnsProperties.$property, [ref] $timeSpan))
                {
                    throw ($script:localizedData.UnableToParseTimeSpan -f $dnsProperties.$property, $property )
                }

                $getDnServerSettingResult.$property = $timeSpan
            }
            else
            {
                $getDnServerSettingResult.$property = $dnsProperties.$property
            }
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

    .PARAMETER EnableIPv6
        Not written yet.

    .PARAMETER EnableOnlineSigning
        Not written yet.

    .PARAMETER EnableDuplicateQuerySuppression
        Not written yet.

    .PARAMETER AllowCnameAtNs
        Not written yet.

    .PARAMETER EnableRsoForRodc
        Not written yet.

    .PARAMETER OpenAclOnProxyUpdates
        Not written yet.

    .PARAMETER NoUpdateDelegations
        Not written yet.

    .PARAMETER EnableUpdateForwarding
        Not written yet.

    .PARAMETER EnableWinsR
        Not written yet.

    .PARAMETER DeleteOutsideGlue
        Not written yet.

    .PARAMETER AppendMsZoneTransferTag
        Not written yet.

    .PARAMETER AllowReadOnlyZoneTransfer
        Not written yet.

    .PARAMETER EnableSendErrorSuppression
        Not written yet.

    .PARAMETER SilentlyIgnoreCnameUpdateConflicts
        Not written yet.

    .PARAMETER EnableIQueryResponseGeneration
        Not written yet.

    .PARAMETER AdminConfigured
        Not written yet.

    .PARAMETER PublishAutoNet
        Not written yet.

    .PARAMETER ReloadException
        Not written yet.

    .PARAMETER IgnoreServerLevelPolicies
        Not written yet.

    .PARAMETER IgnoreAllPolicies
        Not written yet.

    .PARAMETER EnableVersionQuery
        Not written yet.

    .PARAMETER AutoCreateDelegation
        Not written yet.

    .PARAMETER RemoteIPv4RankBoost
        Not written yet.

    .PARAMETER RemoteIPv6RankBoost
        Not written yet.

    .PARAMETER MaximumRodcRsoQueueLength
        Not written yet.

    .PARAMETER MaximumRodcRsoAttemptsPerCycle
        Not written yet.

    .PARAMETER MaxResourceRecordsInNonSecureUpdate
        Not written yet.

    .PARAMETER LocalNetPriorityMask
        Not written yet.

    .PARAMETER TcpReceivePacketSize
        Not written yet.

    .PARAMETER SelfTest
        Not written yet.

    .PARAMETER XfrThrottleMultiplier
        Not written yet.

    .PARAMETER SocketPoolSize
        Not written yet.

    .PARAMETER QuietRecvFaultInterval
        Not written yet.

    .PARAMETER QuietRecvLogInterval
        Not written yet.

    .PARAMETER SyncDsZoneSerial
        Not written yet.

    .PARAMETER ScopeOptionValue
        Not written yet.

    .PARAMETER VirtualizationInstanceOptionValue
        Not written yet.

    .PARAMETER ServerLevelPluginDll
        Not written yet.

    .PARAMETER RootTrustAnchorsURL
        Not written yet.

    .PARAMETER SocketPoolExcludedPortRanges
        Not written yet.

    .PARAMETER LameDelegationTTL
        Not written yet.

    .PARAMETER MaximumSignatureScanPeriod
        Not written yet.

    .PARAMETER MaximumTrustAnchorActiveRefreshInterval
        Not written yet.

    .PARAMETER ZoneWritebackInterval
        Not written yet.
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
        $XfrConnectTimeout,

        [Parameter()]
        [System.Boolean]
        $EnableIPv6,

        [Parameter()]
        [System.Boolean]
        $EnableOnlineSigning,

        [Parameter()]
        [System.Boolean]
        $EnableDuplicateQuerySuppression,

        [Parameter()]
        [System.Boolean]
        $AllowCnameAtNs,

        [Parameter()]
        [System.Boolean]
        $EnableRsoForRodc,

        [Parameter()]
        [System.Boolean]
        $OpenAclOnProxyUpdates,

        [Parameter()]
        [System.Boolean]
        $NoUpdateDelegations,

        [Parameter()]
        [System.Boolean]
        $EnableUpdateForwarding,

        [Parameter()]
        [System.Boolean]
        $EnableWinsR,

        [Parameter()]
        [System.Boolean]
        $DeleteOutsideGlue,

        [Parameter()]
        [System.Boolean]
        $AppendMsZoneTransferTag,

        [Parameter()]
        [System.Boolean]
        $AllowReadOnlyZoneTransfer,

        [Parameter()]
        [System.Boolean]
        $EnableSendErrorSuppression,

        [Parameter()]
        [System.Boolean]
        $SilentlyIgnoreCnameUpdateConflicts,

        [Parameter()]
        [System.Boolean]
        $EnableIQueryResponseGeneration,

        [Parameter()]
        [System.Boolean]
        $AdminConfigured,

        [Parameter()]
        [System.Boolean]
        $PublishAutoNet,

        [Parameter()]
        [System.Boolean]
        $ReloadException,

        [Parameter()]
        [System.Boolean]
        $IgnoreServerLevelPolicies,

        [Parameter()]
        [System.Boolean]
        $IgnoreAllPolicies,

        [Parameter()]
        [System.UInt32]
        $EnableVersionQuery,

        [Parameter()]
        [System.UInt32]
        $AutoCreateDelegation,

        [Parameter()]
        [System.UInt32]
        $RemoteIPv4RankBoost,

        [Parameter()]
        [System.UInt32]
        $RemoteIPv6RankBoost,

        [Parameter()]
        [System.UInt32]
        $MaximumRodcRsoQueueLength,

        [Parameter()]
        [System.UInt32]
        $MaximumRodcRsoAttemptsPerCycle,

        [Parameter()]
        [System.UInt32]
        $MaxResourceRecordsInNonSecureUpdate,

        [Parameter()]
        [System.UInt32]
        $LocalNetPriorityMask,

        [Parameter()]
        [System.UInt32]
        $TcpReceivePacketSize,

        [Parameter()]
        [System.UInt32]
        $SelfTest,

        [Parameter()]
        [System.UInt32]
        $XfrThrottleMultiplier,

        [Parameter()]
        [System.UInt32]
        $SocketPoolSize,

        [Parameter()]
        [System.UInt32]
        $QuietRecvFaultInterval,

        [Parameter()]
        [System.UInt32]
        $QuietRecvLogInterval,

        [Parameter()]
        [System.UInt32]
        $SyncDsZoneSerial,

        [Parameter()]
        [System.UInt32]
        $ScopeOptionValue,

        [Parameter()]
        [System.UInt32]
        $VirtualizationInstanceOptionValue,

        [Parameter()]
        [System.String]
        $ServerLevelPluginDll,

        [Parameter()]
        [System.String]
        $RootTrustAnchorsURL,

        [Parameter()]
        [System.String[]]
        $SocketPoolExcludedPortRanges,

        [Parameter()]
        [System.String]
        $LameDelegationTTL,

        [Parameter()]
        [System.String]
        $MaximumSignatureScanPeriod,

        [Parameter()]
        [System.String]
        $MaximumTrustAnchorActiveRefreshInterval,

        [Parameter()]
        [System.String]
        $ZoneWritebackInterval
    )

    Write-Verbose -Message $script:localizedData.EvaluatingDnsServerSettings

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
