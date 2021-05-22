$availableIpAddresses = Get-NetIPInterface -AddressFamily IPv4 -Dhcp Disabled |
    Get-NetIPAddress |
        Where-Object IPAddress -ne ([IPAddress]::Loopback)

Write-Verbose -Message ('Available IPv4 network interfaces on build worker: {0}' -f (($availableIpAddresses | Select-Object -Property IPAddress, InterfaceAlias, AddressFamily) | Out-String)) -Verbose

$firstIpAddress = $availableIpAddresses | Select-Object -ExpandProperty IPAddress -First 1

Write-Verbose -Message ('Using IP address ''{0}'' for the integration test as first listening IP address.' -f $firstIpAddress) -Verbose

<#
    The value for a property set here should be different than the current state
    in the build worker.
#>
$ConfigurationData = @{
    AllNodes = @(
        @{
            NodeName                                = 'localhost'
            CertificateFile                         = $env:DscPublicCertificatePath
            DnsServer                               = 'localhost'
            AddressAnswerLimit                      = 5
            AllowUpdate                             = $false
            AutoCacheUpdate                         = $true
            AutoConfigFileZones                     = 2
            BindSecondaries                         = $true
            BootMethod                              = 2
            DisableAutoReverseZone                  = $true
            EnableDirectoryPartitions               = $true
            EnableDnsSec                            = $false
            ForwardDelegations                      = $true
            <#
                At least one of the listening IP addresses that is specified must
                be present on a network interface on the host running the test.
            #>
            ListeningIPAddress                      = @($firstIpAddress, '10.0.0.10')
            LocalNetPriority                        = $false
            LooseWildcarding                        = $true
            NameCheckFlag                           = 1
            RoundRobin                              = $false
            RpcProtocol                             = 4
            SendPort                                = 100
            StrictFileParsing                       = $true
            UpdateOptions                           = 784
            WriteAuthorityNS                        = $true
            XfrConnectTimeout                       = 40
            ServerLevelPluginDll                    = 'C:\temp\plugin.dll'

            AdminConfigured                         = $false
            AllowCnameAtNs                          = $false
            AllowReadOnlyZoneTransfer               = $true
            AppendMsZoneTransferTag                 = $true
            AutoCreateDelegation                    = 1
            DeleteOutsideGlue                       = $true
            EnableDuplicateQuerySuppression         = $false
            EnableIPv6                              = $false
            EnableIQueryResponseGeneration          = $true
            EnableOnlineSigning                     = $false
            EnableRsoForRodc                        = $false
            EnableSendErrorSuppression              = $false
            EnableUpdateForwarding                  = $true
            EnableVersionQuery                      = 1
            EnableWinsR                             = $false
            IgnoreAllPolicies                       = $true
            IgnoreServerLevelPolicies               = $true
            IsReadOnlyDC                            = $true
            LameDelegationTTL                       = 00:00:10
            LocalNetPriorityMask                    = 254
            MaximumRodcRsoAttemptsPerCycle          = 110
            MaximumRodcRsoQueueLength               = 350
            MaximumSignatureScanPeriod              = 3.00:00:00
            MaximumTrustAnchorActiveRefreshInterval = 16.00:00:00
            MaximumUdpPacketSize                    = 4500
            MaxResourceRecordsInNonSecureUpdate     = 40
            NoUpdateDelegations                     = $true
            OpenAclOnProxyUpdates                   = $false
            PublishAutoNet                          = $true
            QuietRecvFaultInterval                  = 1
            QuietRecvLogInterval                    = 1
            ReloadException                         = $true
            RemoteIPv4RankBoost                     = 4
            RemoteIPv6RankBoost                     = 4
            RootTrustAnchorsURL                     = 'https://data.iana.org/new-root-anchors/root-anchors.xml'
            ScopeOptionValue                        = 1
            SelfTest                                = 0
            SilentlyIgnoreCnameUpdateConflicts      = $true
            SocketPoolExcludedPortRanges            = @(5353)
            SocketPoolSize                          = 3500
            SyncDsZoneSerial                        = 1
            TcpReceivePacketSize                    = 65535
            VirtualizationInstanceOptionValue       = 1
            XfrThrottleMultiplier                   = 11
            ZoneWritebackInterval                   = 00:02:00
        }
    )
}

Configuration DSC_DnsServerSetting_SetSettings_Config
{
    Import-DscResource -ModuleName 'DnsServerDsc'

    node $AllNodes.NodeName
    {
        DnsServerSetting 'Integration_Test'
        {

            DnsServer                 = $Node.DnsServer
            AddressAnswerLimit        = $Node.AddressAnswerLimit
            AllowUpdate               = $Node.AllowUpdate
            AutoCacheUpdate           = $Node.AutoCacheUpdate
            AutoConfigFileZones       = $Node.AutoConfigFileZones
            BindSecondaries           = $Node.BindSecondaries
            BootMethod                = $Node.BootMethod
            DisableAutoReverseZone    = $Node.DisableAutoReverseZone
            EnableDirectoryPartitions = $Node.EnableDirectoryPartitions
            EnableDnsSec              = $Node.EnableDnsSec
            ForwardDelegations        = $Node.ForwardDelegations
            ListeningIPAddress        = $Node.ListeningIPAddress
            LocalNetPriority          = $Node.LocalNetPriority
            LooseWildcarding          = $Node.LooseWildcarding
            NameCheckFlag             = $Node.NameCheckFlag
            RoundRobin                = $Node.RoundRobin
            RpcProtocol               = $Node.RpcProtocol
            SendPort                  = $Node.SendPort
            StrictFileParsing         = $Node.StrictFileParsing
            UpdateOptions             = $Node.UpdateOptions
            WriteAuthorityNS          = $Node.WriteAuthorityNS
            XfrConnectTimeout         = $Node.XfrConnectTimeout
        }
    }
}
