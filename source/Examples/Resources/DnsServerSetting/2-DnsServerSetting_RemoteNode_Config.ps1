<#PSScriptInfo

.VERSION 1.0.0

.GUID 4c4f3794-41e8-4035-ba5c-a478675738e3

.AUTHOR DSC Community

.COMPANYNAME DSC Community

.COPYRIGHT DSC Community contributors. All rights reserved.

.TAGS DSCConfiguration

.LICENSEURI https://github.com/dsccommunity/DnsServerDsc/blob/main/LICENSE

.PROJECTURI https://github.com/dsccommunity/DnsServerDsc

.ICONURI https://dsccommunity.org/images/DSC_Logo_300p.png

.EXTERNALMODULEDEPENDENCIES

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES
Updated author, copyright notice, and URLs.

.PRIVATEDATA 2016-Datacenter,2016-Datacenter-Server-Core

#>

#Requires -Module DnsServerDsc


<#
    .DESCRIPTION
        This configuration will manage the DNS server settings on the current
        node.
#>

Configuration DnsServerSetting_RemoteNode_Config
{
    Import-DscResource -ModuleName 'DnsServerDsc'

    Node localhost
    {
        DnsServerSetting 'DnsServerProperties'
        {
            DnsServer                               = 'dns1.company.local'
            LocalNetPriority                        = $true
            RoundRobin                              = $true
            RpcProtocol                             = 0
            NameCheckFlag                           = 2
            AutoConfigFileZones                     = 1
            AddressAnswerLimit                      = 0
            UpdateOptions                           = 783
            DisableAutoReverseZone                  = $false
            StrictFileParsing                       = $false
            EnableDirectoryPartitions               = $false
            XfrConnectTimeout                       = 30
            BootMethod                              = 3
            AllowUpdate                             = $true
            LooseWildcarding                        = $false
            BindSecondaries                         = $false
            AutoCacheUpdate                         = $false
            EnableDnsSec                            = $true
            SendPort                                = 0
            WriteAuthorityNS                        = $false
            ListeningIPAddress                      = @('192.168.1.10', '192.168.2.10')
            ForwardDelegations                      = $false
            EnableIPv6                              = $true
            EnableOnlineSigning                     = $true
            EnableDuplicateQuerySuppression         = $true
            AllowCnameAtNs                          = $true
            EnableRsoForRodc                        = $true
            OpenAclOnProxyUpdates                   = $true
            NoUpdateDelegations                     = $false
            EnableUpdateForwarding                  = $false
            EnableWinsR                             = $true
            DeleteOutsideGlue                       = $false
            AppendMsZoneTransferTag                 = $false
            AllowReadOnlyZoneTransfer               = $false
            EnableSendErrorSuppression              = $true
            SilentlyIgnoreCnameUpdateConflicts      = $false
            EnableIQueryResponseGeneration          = $false
            AdminConfigured                         = $true
            PublishAutoNet                          = $false
            ReloadException                         = $false
            IgnoreServerLevelPolicies               = $false
            IgnoreAllPolicies                       = $false
            EnableVersionQuery                      = 0
            AutoCreateDelegation                    = 2
            RemoteIPv4RankBoost                     = 5
            RemoteIPv6RankBoost                     = 0
            MaximumRodcRsoQueueLength               = 300
            MaximumRodcRsoAttemptsPerCycle          = 100
            MaxResourceRecordsInNonSecureUpdate     = 30
            LocalNetPriorityMask                    = 255
            TcpReceivePacketSize                    = 65536
            SelfTest                                = 4294967295
            XfrThrottleMultiplier                   = 10
            SocketPoolSize                          = 2500
            QuietRecvFaultInterval                  = 0
            QuietRecvLogInterval                    = 0
            SyncDsZoneSerial                        = 2
            ScopeOptionValue                        = 0
            VirtualizationInstanceOptionValue       = 0
            ServerLevelPluginDll                    = 'C:\dns\plugin.dll'
            RootTrustAnchorsURL                     = 'https://data.iana.org/root-anchors/oroot-anchors.xml'
            SocketPoolExcludedPortRanges            = @()
            LameDelegationTTL                       = '00:00:00'
            MaximumSignatureScanPeriod              = '2.00:00:00'
            MaximumTrustAnchorActiveRefreshInterval = '15.00:00:00'
            ZoneWritebackInterval                   = '00:01:00'
        }
    }
}
