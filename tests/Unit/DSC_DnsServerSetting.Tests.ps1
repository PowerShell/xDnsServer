$script:dscModuleName = 'DnsServerDsc'
$script:dscResourceName = 'DSC_DnsServerSetting'

function Invoke-TestSetup
{
    try
    {
        Import-Module -Name DscResource.Test -Force -ErrorAction 'Stop'
    }
    catch [System.IO.FileNotFoundException]
    {
        throw 'DscResource.Test module dependency not found. Please run ".\build.ps1 -Tasks build" first.'
    }

    $script:testEnvironment = Initialize-TestEnvironment `
        -DSCModuleName $script:dscModuleName `
        -DSCResourceName $script:dscResourceName `
        -ResourceType 'Mof' `
        -TestType 'Unit'

    Import-Module (Join-Path -Path $PSScriptRoot -ChildPath 'Stubs\DnsServer.psm1') -Force
}

function Invoke-TestCleanup
{
    Restore-TestEnvironment -TestEnvironment $script:testEnvironment
}

Invoke-TestSetup

try
{
    InModuleScope $script:dscResourceName {
        Describe 'DSC_DnsServerSetting\Get-TargetResource' -Tag 'Get' {
            BeforeAll {
                Mock -CommandName Assert-Module
                Mock -CommandName Get-DnsServerSetting -MockWith {
                    return @{
                        DnsServer                               = 'dns1.company.local'
                        LocalNetPriority                        = $false
                        RoundRobin                              = $false
                        RpcProtocol                             = 1
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
                        RootTrustAnchorsURL                     = 'https://data.iana.org/root-anchors/root-anchors.xml'
                        SocketPoolExcludedPortRanges            = @(5353, 5454)
                        LameDelegationTTL                       = New-TimeSpan -Seconds 0
                        MaximumSignatureScanPeriod              = New-TimeSpan -Days 2
                        MaximumTrustAnchorActiveRefreshInterval = New-TimeSpan -Days 15
                        ZoneWritebackInterval                   = New-TimeSpan -Minutes 1

                        # Read-only properties
                        DsAvailable                             = $true
                        MajorVersion                            = 10
                        MinorVersion                            = 0
                        BuildNumber                             = 14393
                        IsReadOnlyDC                            = $false
                        AllIPAddress                            = @('fe80::e82e:70b7:f1d4:f695', '192.168.1.10', '192.168.2.10')
                        ForestDirectoryPartitionBaseName        = 'ForestDnsZones'
                        DomainDirectoryPartitionBaseName        = 'DomainDnsZones'
                        MaximumUdpPacketSize                    = 4000
                    }
                }
            }

            Context 'When the system is in the desired state' {
                It "Should return the correct values for each property" {
                    $getTargetResourceResult = Get-TargetResource -DnsServer 'dns1.company.local'

                    $getTargetResourceResult.LocalNetPriority | Should -BeFalse
                    $getTargetResourceResult.RoundRobin | Should -BeFalse
                    $getTargetResourceResult.RpcProtocol | Should -Be 1

                    # Read-only properties
                    $getTargetResourceResult.DsAvailable | Should -BeTrue
                    $getTargetResourceResult.MajorVersion | Should -Be 10
                    $getTargetResourceResult.MinorVersion | Should -Be 0
                    $getTargetResourceResult.BuildNumber | Should -Be 14393
                    $getTargetResourceResult.IsReadOnlyDC | Should -BeFalse
                    $getTargetResourceResult.ForestDirectoryPartitionBaseName | Should -Be 'ForestDnsZones'
                    $getTargetResourceResult.DomainDirectoryPartitionBaseName | Should -Be 'DomainDnsZones'
                    $getTargetResourceResult.MaximumUdpPacketSize | Should -Be 4000
                    $getTargetResourceResult.NameCheckFlag | Should -Be 2
                    $getTargetResourceResult.AutoConfigFileZones | Should -Be 1
                    $getTargetResourceResult.AddressAnswerLimit | Should -Be 0
                    $getTargetResourceResult.UpdateOptions | Should -Be 783
                    $getTargetResourceResult.DisableAutoReverseZone | Should -BeFalse
                    $getTargetResourceResult.StrictFileParsing | Should -BeFalse
                    $getTargetResourceResult.EnableDirectoryPartitions | Should -BeFalse
                    $getTargetResourceResult.XfrConnectTimeout | Should -Be 30
                    $getTargetResourceResult.BootMethod | Should -Be 3
                    $getTargetResourceResult.AllowUpdate | Should -BeTrue
                    $getTargetResourceResult.LooseWildcarding | Should -BeFalse
                    $getTargetResourceResult.BindSecondaries | Should -BeFalse
                    $getTargetResourceResult.AutoCacheUpdate | Should -BeFalse
                    $getTargetResourceResult.EnableDnsSec | Should -BeTrue
                    $getTargetResourceResult.SendPort | Should -Be 0
                    $getTargetResourceResult.WriteAuthorityNS | Should -BeFalse
                    $getTargetResourceResult.ForwardDelegations | Should -BeFalse
                    $getTargetResourceResult.EnableIPv6 | Should -BeTrue
                    $getTargetResourceResult.EnableOnlineSigning | Should -BeTrue
                    $getTargetResourceResult.EnableDuplicateQuerySuppression | Should -BeTrue
                    $getTargetResourceResult.AllowCnameAtNs | Should -BeTrue
                    $getTargetResourceResult.EnableRsoForRodc | Should -BeTrue
                    $getTargetResourceResult.OpenAclOnProxyUpdates | Should -BeTrue
                    $getTargetResourceResult.NoUpdateDelegations | Should -BeFalse
                    $getTargetResourceResult.EnableUpdateForwarding | Should -BeFalse
                    $getTargetResourceResult.EnableWinsR | Should -BeTrue
                    $getTargetResourceResult.DeleteOutsideGlue | Should -BeFalse
                    $getTargetResourceResult.AppendMsZoneTransferTag | Should -BeFalse
                    $getTargetResourceResult.AllowReadOnlyZoneTransfer | Should -BeFalse
                    $getTargetResourceResult.EnableSendErrorSuppression | Should -BeTrue
                    $getTargetResourceResult.SilentlyIgnoreCnameUpdateConflicts | Should -BeFalse
                    $getTargetResourceResult.EnableIQueryResponseGeneration | Should -BeFalse
                    $getTargetResourceResult.AdminConfigured | Should -BeTrue
                    $getTargetResourceResult.PublishAutoNet | Should -BeFalse
                    $getTargetResourceResult.ReloadException | Should -BeFalse
                    $getTargetResourceResult.IgnoreServerLevelPolicies | Should -BeFalse
                    $getTargetResourceResult.IgnoreAllPolicies | Should -BeFalse
                    $getTargetResourceResult.EnableVersionQuery | Should -Be 0
                    $getTargetResourceResult.AutoCreateDelegation | Should -Be 2
                    $getTargetResourceResult.RemoteIPv4RankBoost | Should -Be 5
                    $getTargetResourceResult.RemoteIPv6RankBoost | Should -Be 0
                    $getTargetResourceResult.MaximumRodcRsoQueueLength | Should -Be 300
                    $getTargetResourceResult.MaximumRodcRsoAttemptsPerCycle | Should -Be 100
                    $getTargetResourceResult.MaxResourceRecordsInNonSecureUpdate | Should -Be 30
                    $getTargetResourceResult.LocalNetPriorityMask | Should -Be 255
                    $getTargetResourceResult.TcpReceivePacketSize | Should -Be 65536
                    $getTargetResourceResult.SelfTest | Should -Be 4294967295
                    $getTargetResourceResult.XfrThrottleMultiplier | Should -Be 10
                    $getTargetResourceResult.SocketPoolSize | Should -Be 2500
                    $getTargetResourceResult.QuietRecvFaultInterval | Should -Be 0
                    $getTargetResourceResult.QuietRecvLogInterval | Should -Be 0
                    $getTargetResourceResult.SyncDsZoneSerial | Should -Be 2
                    $getTargetResourceResult.ScopeOptionValue | Should -Be 0
                    $getTargetResourceResult.VirtualizationInstanceOptionValue | Should -Be 0
                    $getTargetResourceResult.ServerLevelPluginDll | Should -Be 'C:\dns\plugin.dll'
                    $getTargetResourceResult.RootTrustAnchorsURL | Should -Be 'https://data.iana.org/root-anchors/root-anchors.xml'
                    $getTargetResourceResult.LameDelegationTTL | Should -Be '00:00:00'
                    $getTargetResourceResult.MaximumSignatureScanPeriod | Should -Be '2.00:00:00'
                    $getTargetResourceResult.MaximumTrustAnchorActiveRefreshInterval | Should -Be '15.00:00:00'
                    $getTargetResourceResult.ZoneWritebackInterval | Should -Be '00:01:00'

                    $getTargetResourceResult.ListeningIPAddress | Should -HaveCount 2
                    $getTargetResourceResult.ListeningIPAddress | Should -Contain '192.168.1.10'
                    $getTargetResourceResult.ListeningIPAddress | Should -Contain '192.168.2.10'

                    $getTargetResourceResult.AllIPAddress | Should -HaveCount 3
                    $getTargetResourceResult.AllIPAddress | Should -Contain 'fe80::e82e:70b7:f1d4:f695'
                    $getTargetResourceResult.AllIPAddress | Should -Contain '192.168.1.10'
                    $getTargetResourceResult.AllIPAddress | Should -Contain '192.168.2.10'

                    $getTargetResourceResult.SocketPoolExcludedPortRanges | Should -HaveCount 2
                    $getTargetResourceResult.SocketPoolExcludedPortRanges | Should -Contain 5353
                    $getTargetResourceResult.SocketPoolExcludedPortRanges | Should -Contain 5454

                }
            }
        }

        Describe 'DSC_DnsServerSetting\Test-TargetResource' -Tag 'Test' {
            BeforeAll {
                Mock -CommandName Assert-Module
            }

            Context 'When the system is not in the desired state' {
                BeforeAll {
                    Mock -CommandName Get-TargetResource -MockWith {
                        return @{
                            DnsServer                               = 'dns1.company.local'
                            LocalNetPriority                        = $true
                            RoundRobin                              = $true
                            RpcProtocol                             = [System.UInt32] 0
                            NameCheckFlag                           = [System.UInt32] 2
                            AutoConfigFileZones                     = [System.UInt32] 1
                            AddressAnswerLimit                      = [System.UInt32] 0
                            UpdateOptions                           = [System.UInt32] 783
                            DisableAutoReverseZone                  = $false
                            StrictFileParsing                       = $false
                            EnableDirectoryPartitions               = $false
                            XfrConnectTimeout                       = [System.UInt32] 30
                            BootMethod                              = [System.UInt32] 3
                            AllowUpdate                             = $true
                            LooseWildcarding                        = $false
                            BindSecondaries                         = $false
                            AutoCacheUpdate                         = $false
                            EnableDnsSec                            = $true
                            SendPort                                = [System.UInt32] 0
                            WriteAuthorityNS                        = $false
                            ListeningIPAddress                      = [System.String[]] @('192.168.1.10', '192.168.2.10')
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
                            EnableVersionQuery                      = [System.UInt32] 0
                            AutoCreateDelegation                    = [System.UInt32] 2
                            RemoteIPv4RankBoost                     = [System.UInt32] 5
                            RemoteIPv6RankBoost                     = [System.UInt32] 0
                            MaximumRodcRsoQueueLength               = [System.UInt32] 300
                            MaximumRodcRsoAttemptsPerCycle          = [System.UInt32] 100
                            MaxResourceRecordsInNonSecureUpdate     = [System.UInt32] 30
                            LocalNetPriorityMask                    = [System.UInt32] 255
                            TcpReceivePacketSize                    = [System.UInt32] 65536
                            SelfTest                                = [System.UInt32] 4294967295
                            XfrThrottleMultiplier                   = [System.UInt32] 10
                            SocketPoolSize                          = [System.UInt32] 2500
                            QuietRecvFaultInterval                  = [System.UInt32] 0
                            QuietRecvLogInterval                    = [System.UInt32] 0
                            SyncDsZoneSerial                        = [System.UInt32] 2
                            ScopeOptionValue                        = [System.UInt32] 0
                            VirtualizationInstanceOptionValue       = [System.UInt32] 0
                            ServerLevelPluginDll                    = 'C:\dns\plugin.dll'
                            RootTrustAnchorsURL                     = 'https://data.iana.org/root-anchors/oroot-anchors.xml'
                            SocketPoolExcludedPortRanges            = $null
                            LameDelegationTTL                       = '00:00:00'
                            MaximumSignatureScanPeriod              = '2.00:00:00'
                            MaximumTrustAnchorActiveRefreshInterval = '15.00:00:00'
                            ZoneWritebackInterval                   = '00:01:00'
                        }
                    }

                    $testCases = @(
                        @{
                            PropertyName  = 'LocalNetPriority'
                            PropertyValue = $false
                        }
                        @{
                            PropertyName  = 'RoundRobin'
                            PropertyValue = $false
                        }
                        @{
                            PropertyName  = 'RpcProtocol'
                            PropertyValue = [System.UInt32] 1
                        }
                        @{
                            PropertyName  = 'NameCheckFlag'
                            PropertyValue = [System.UInt32] 1
                        }
                        @{
                            PropertyName  = 'AutoConfigFileZones'
                            PropertyValue = [System.UInt32] 0
                        }
                        @{
                            PropertyName  = 'AddressAnswerLimit'
                            PropertyValue = [System.UInt32] 1
                        }
                        @{
                            PropertyName  = 'UpdateOptions'
                            PropertyValue = [System.UInt32] 784
                        }
                        @{
                            PropertyName  = 'DisableAutoReverseZone'
                            PropertyValue = $true
                        }
                        @{
                            PropertyName  = 'StrictFileParsing'
                            PropertyValue = $true
                        }
                        @{
                            PropertyName  = 'EnableDirectoryPartitions'
                            PropertyValue = $true
                        }
                        @{
                            PropertyName  = 'XfrConnectTimeout'
                            PropertyValue = [System.UInt32] 40
                        }
                        @{
                            PropertyName  = 'BootMethod'
                            PropertyValue = [System.UInt32] 2
                        }
                        @{
                            PropertyName  = 'AllowUpdate'
                            PropertyValue = $false
                        }
                        @{
                            PropertyName  = 'LooseWildcarding'
                            PropertyValue = $true
                        }
                        @{
                            PropertyName  = 'BindSecondaries'
                            PropertyValue = $true
                        }
                        @{
                            PropertyName  = 'AutoCacheUpdate'
                            PropertyValue = $true
                        }
                        @{
                            PropertyName  = 'EnableDnsSec'
                            PropertyValue = $false
                        }
                        @{
                            PropertyName  = 'SendPort'
                            PropertyValue = [System.UInt32] 100
                        }
                        @{
                            PropertyName  = 'WriteAuthorityNS'
                            PropertyValue = $true
                        }
                        @{
                            PropertyName  = 'ForwardDelegations'
                            PropertyValue = $true
                        }
                        @{
                            PropertyName  = 'ListeningIPAddress'
                            PropertyValue = [System.String[]] @('fe80::e82e:70b7:f1d4:f695')
                        }
                        @{
                            PropertyName  = 'EnableIPv6'
                            PropertyValue = $false
                        }
                        @{
                            PropertyName  = 'EnableOnlineSigning'
                            PropertyValue = $false
                        }
                        @{
                            PropertyName  = 'EnableDuplicateQuerySuppression'
                            PropertyValue = $false
                        }
                        @{
                            PropertyName  = 'AllowCnameAtNs'
                            PropertyValue = $false
                        }
                        @{
                            PropertyName  = 'EnableRsoForRodc'
                            PropertyValue = $false
                        }
                        @{
                            PropertyName  = 'OpenAclOnProxyUpdates'
                            PropertyValue = $false
                        }
                        @{
                            PropertyName  = 'NoUpdateDelegations'
                            PropertyValue = $true
                        }
                        @{
                            PropertyName  = 'EnableUpdateForwarding'
                            PropertyValue = $true
                        }
                        @{
                            PropertyName  = 'EnableWinsR'
                            PropertyValue = $false
                        }
                        @{
                            PropertyName  = 'DeleteOutsideGlue'
                            PropertyValue = $true
                        }
                        @{
                            PropertyName  = 'AppendMsZoneTransferTag'
                            PropertyValue = $true
                        }
                        @{
                            PropertyName  = 'AllowReadOnlyZoneTransfer'
                            PropertyValue = $true
                        }
                        @{
                            PropertyName  = 'EnableSendErrorSuppression'
                            PropertyValue = $false
                        }
                        @{
                            PropertyName  = 'SilentlyIgnoreCnameUpdateConflicts'
                            PropertyValue = $true
                        }
                        @{
                            PropertyName  = 'EnableIQueryResponseGeneration'
                            PropertyValue = $true
                        }
                        @{
                            PropertyName  = 'AdminConfigured'
                            PropertyValue = $false
                        }
                        @{
                            PropertyName  = 'PublishAutoNet'
                            PropertyValue = $true
                        }
                        @{
                            PropertyName  = 'ReloadException'
                            PropertyValue = $true
                        }
                        @{
                            PropertyName  = 'IgnoreServerLevelPolicies'
                            PropertyValue = $true
                        }
                        @{
                            PropertyName  = 'IgnoreAllPolicies'
                            PropertyValue = $true
                        }
                        @{
                            PropertyName  = 'EnableVersionQuery'
                            PropertyValue = [System.UInt32] 1
                        }
                        @{
                            PropertyName  = 'AutoCreateDelegation'
                            PropertyValue = [System.UInt32] 1
                        }
                        @{
                            PropertyName  = 'RemoteIPv4RankBoost'
                            PropertyValue = [System.UInt32] 4
                        }
                        @{
                            PropertyName  = 'RemoteIPv6RankBoost'
                            PropertyValue = [System.UInt32] 1
                        }
                        @{
                            PropertyName  = 'MaximumRodcRsoQueueLength'
                            PropertyValue = [System.UInt32] 350
                        }
                        @{
                            PropertyName  = 'MaximumRodcRsoAttemptsPerCycle'
                            PropertyValue = [System.UInt32] 150
                        }
                        @{
                            PropertyName  = 'MaxResourceRecordsInNonSecureUpdate'
                            PropertyValue = [System.UInt32] 40
                        }
                        @{
                            PropertyName  = 'LocalNetPriorityMask'
                            PropertyValue = [System.UInt32] 254
                        }
                        @{
                            PropertyName  = 'TcpReceivePacketSize'
                            PropertyValue = [System.UInt32] 65000
                        }
                        @{
                            PropertyName  = 'SelfTest'
                            PropertyValue = [System.UInt32] 4000000000
                        }
                        @{
                            PropertyName  = 'XfrThrottleMultiplier'
                            PropertyValue = [System.UInt32] 15
                        }
                        @{
                            PropertyName  = 'SocketPoolSize'
                            PropertyValue = [System.UInt32] 3000
                        }
                        @{
                            PropertyName  = 'QuietRecvFaultInterval'
                            PropertyValue = [System.UInt32] 1
                        }
                        @{
                            PropertyName  = 'QuietRecvLogInterval'
                            PropertyValue = [System.UInt32] 1
                        }
                        @{
                            PropertyName  = 'SyncDsZoneSerial'
                            PropertyValue = [System.UInt32] 1
                        }
                        @{
                            PropertyName  = 'ScopeOptionValue'
                            PropertyValue = [System.UInt32] 1
                        }
                        @{
                            PropertyName  = 'VirtualizationInstanceOptionValue'
                            PropertyValue = [System.UInt32] 1
                        }
                        @{
                            PropertyName  = 'ServerLevelPluginDll'
                            PropertyValue = 'C:\dns\oldPlugin.dll'
                        }
                        @{
                            PropertyName  = 'RootTrustAnchorsURL'
                            PropertyValue = 'https://data.iana.org/old-root-anchors/root-anchors.xml'
                        }
                        @{
                            PropertyName  = 'SocketPoolExcludedPortRanges'
                            PropertyValue = [System.String[]] @(5353, 5454)
                        }
                        @{
                            PropertyName  = 'LameDelegationTTL'
                            PropertyValue = '00:00:01'
                        }
                        @{
                            PropertyName  = 'MaximumSignatureScanPeriod'
                            PropertyValue = '3.00:00:00'
                        }
                        @{
                            PropertyName  = 'MaximumTrustAnchorActiveRefreshInterval'
                            PropertyValue = '20.00:00:00'
                        }
                        @{
                            PropertyName  = 'ZoneWritebackInterval'
                            PropertyValue = '00:00:30'
                        }
                    )
                }

                It 'Should return $false for property <PropertyName>' -TestCases $testCases {
                    param
                    (
                        $PropertyName,
                        $PropertyValue
                    )

                    $testTargetResourceParameters = @{
                        DnsServer     = 'dns1.company.local'
                        $PropertyName = $PropertyValue
                    }

                    Test-TargetResource @testTargetResourceParameters | Should -BeFalse
                }
            }

            Context 'When the system is in the desired state' {
                BeforeAll {
                    Mock -CommandName Get-TargetResource -MockWith {
                        return @{
                            DnsServer                               = 'dns1.company.local'
                            LocalNetPriority                        = $true
                            RoundRobin                              = $true
                            RpcProtocol                             = [System.UInt32] 0
                            NameCheckFlag                           = [System.UInt32] 2
                            AutoConfigFileZones                     = [System.UInt32] 1
                            AddressAnswerLimit                      = [System.UInt32] 0
                            UpdateOptions                           = [System.UInt32] 783
                            DisableAutoReverseZone                  = $false
                            StrictFileParsing                       = $false
                            EnableDirectoryPartitions               = $false
                            XfrConnectTimeout                       = [System.UInt32] 30
                            BootMethod                              = [System.UInt32] 3
                            AllowUpdate                             = $true
                            LooseWildcarding                        = $false
                            BindSecondaries                         = $false
                            AutoCacheUpdate                         = $false
                            EnableDnsSec                            = $true
                            SendPort                                = [System.UInt32] 0
                            WriteAuthorityNS                        = $false
                            ListeningIPAddress                      = [System.String[]] @('192.168.1.10', '192.168.2.10')
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
                            EnableVersionQuery                      = [System.UInt32] 0
                            AutoCreateDelegation                    = [System.UInt32] 2
                            RemoteIPv4RankBoost                     = [System.UInt32] 5
                            RemoteIPv6RankBoost                     = [System.UInt32] 0
                            MaximumRodcRsoQueueLength               = [System.UInt32] 300
                            MaximumRodcRsoAttemptsPerCycle          = [System.UInt32] 100
                            MaxResourceRecordsInNonSecureUpdate     = [System.UInt32] 30
                            LocalNetPriorityMask                    = [System.UInt32] 255
                            TcpReceivePacketSize                    = [System.UInt32] 65536
                            SelfTest                                = [System.UInt32] 4294967295
                            XfrThrottleMultiplier                   = [System.UInt32] 10
                            SocketPoolSize                          = [System.UInt32] 2500
                            QuietRecvFaultInterval                  = [System.UInt32] 0
                            QuietRecvLogInterval                    = [System.UInt32] 0
                            SyncDsZoneSerial                        = [System.UInt32] 2
                            ScopeOptionValue                        = [System.UInt32] 0
                            VirtualizationInstanceOptionValue       = [System.UInt32] 0
                            ServerLevelPluginDll                    = 'C:\dns\plugin.dll'
                            RootTrustAnchorsURL                     = 'https://data.iana.org/root-anchors/root-anchors.xml'
                            SocketPoolExcludedPortRanges            = [System.String[]] @(5353, 5454)
                            LameDelegationTTL                       = '00:00:00'
                            MaximumSignatureScanPeriod              = '2.00:00:00'
                            MaximumTrustAnchorActiveRefreshInterval = '15.00:00:00'
                            ZoneWritebackInterval                   = '00:01:00'
                        }
                    }

                    $testCases = @(
                        @{
                            PropertyName  = 'LocalNetPriority'
                            PropertyValue = $true
                        }
                        @{
                            PropertyName  = 'RoundRobin'
                            PropertyValue = $true
                        }
                        @{
                            PropertyName  = 'RpcProtocol'
                            PropertyValue = [System.UInt32] 0
                        }
                        @{
                            PropertyName  = 'NameCheckFlag'
                            PropertyValue = [System.UInt32] 2
                        }
                        @{
                            PropertyName  = 'AutoConfigFileZones'
                            PropertyValue = [System.UInt32] 1
                        }
                        @{
                            PropertyName  = 'AddressAnswerLimit'
                            PropertyValue = [System.UInt32] 0
                        }
                        @{
                            PropertyName  = 'UpdateOptions'
                            PropertyValue = [System.UInt32] 783
                        }
                        @{
                            PropertyName  = 'DisableAutoReverseZone'
                            PropertyValue = $false
                        }
                        @{
                            PropertyName  = 'StrictFileParsing'
                            PropertyValue = $false
                        }
                        @{
                            PropertyName  = 'EnableDirectoryPartitions'
                            PropertyValue = $false
                        }
                        @{
                            PropertyName  = 'XfrConnectTimeout'
                            PropertyValue = [System.UInt32] 30
                        }
                        @{
                            PropertyName  = 'BootMethod'
                            PropertyValue = [System.UInt32] 3
                        }
                        @{
                            PropertyName  = 'AllowUpdate'
                            PropertyValue = $true
                        }
                        @{
                            PropertyName  = 'LooseWildcarding'
                            PropertyValue = $false
                        }
                        @{
                            PropertyName  = 'BindSecondaries'
                            PropertyValue = $false
                        }
                        @{
                            PropertyName  = 'AutoCacheUpdate'
                            PropertyValue = $false
                        }
                        @{
                            PropertyName  = 'EnableDnsSec'
                            PropertyValue = $true
                        }
                        @{
                            PropertyName  = 'SendPort'
                            PropertyValue = [System.UInt32] 0
                        }
                        @{
                            PropertyName  = 'WriteAuthorityNS'
                            PropertyValue = $false
                        }
                        @{
                            PropertyName  = 'ForwardDelegations'
                            PropertyValue = $false
                        }
                        @{
                            PropertyName  = 'ListeningIPAddress'
                            PropertyValue = [System.String[]] @('192.168.1.10', '192.168.2.10')
                        }
                        @{
                            PropertyName  = 'EnableIPv6'
                            PropertyValue = $true
                        }
                        @{
                            PropertyName  = 'EnableOnlineSigning'
                            PropertyValue = $true
                        }
                        @{
                            PropertyName  = 'EnableDuplicateQuerySuppression'
                            PropertyValue = $true
                        }
                        @{
                            PropertyName  = 'AllowCnameAtNs'
                            PropertyValue = $true
                        }
                        @{
                            PropertyName  = 'EnableRsoForRodc'
                            PropertyValue = $true
                        }
                        @{
                            PropertyName  = 'OpenAclOnProxyUpdates'
                            PropertyValue = $true
                        }
                        @{
                            PropertyName  = 'NoUpdateDelegations'
                            PropertyValue = $false
                        }
                        @{
                            PropertyName  = 'EnableUpdateForwarding'
                            PropertyValue = $false
                        }
                        @{
                            PropertyName  = 'EnableWinsR'
                            PropertyValue = $true
                        }
                        @{
                            PropertyName  = 'DeleteOutsideGlue'
                            PropertyValue = $false
                        }
                        @{
                            PropertyName  = 'AppendMsZoneTransferTag'
                            PropertyValue = $false
                        }
                        @{
                            PropertyName  = 'AllowReadOnlyZoneTransfer'
                            PropertyValue = $false
                        }
                        @{
                            PropertyName  = 'EnableSendErrorSuppression'
                            PropertyValue = $true
                        }
                        @{
                            PropertyName  = 'SilentlyIgnoreCnameUpdateConflicts'
                            PropertyValue = $false
                        }
                        @{
                            PropertyName  = 'EnableIQueryResponseGeneration'
                            PropertyValue = $false
                        }
                        @{
                            PropertyName  = 'AdminConfigured'
                            PropertyValue = $true
                        }
                        @{
                            PropertyName  = 'PublishAutoNet'
                            PropertyValue = $false
                        }
                        @{
                            PropertyName  = 'ReloadException'
                            PropertyValue = $false
                        }
                        @{
                            PropertyName  = 'IgnoreServerLevelPolicies'
                            PropertyValue = $false
                        }
                        @{
                            PropertyName  = 'IgnoreAllPolicies'
                            PropertyValue = $false
                        }
                        @{
                            PropertyName  = 'EnableVersionQuery'
                            PropertyValue = [System.UInt32] 0
                        }
                        @{
                            PropertyName  = 'AutoCreateDelegation'
                            PropertyValue = [System.UInt32] 2
                        }
                        @{
                            PropertyName  = 'RemoteIPv4RankBoost'
                            PropertyValue = [System.UInt32] 5
                        }
                        @{
                            PropertyName  = 'RemoteIPv6RankBoost'
                            PropertyValue = [System.UInt32] 0
                        }
                        @{
                            PropertyName  = 'MaximumRodcRsoQueueLength'
                            PropertyValue = [System.UInt32] 300
                        }
                        @{
                            PropertyName  = 'MaximumRodcRsoAttemptsPerCycle'
                            PropertyValue = [System.UInt32] 100
                        }
                        @{
                            PropertyName  = 'MaxResourceRecordsInNonSecureUpdate'
                            PropertyValue = [System.UInt32] 30
                        }
                        @{
                            PropertyName  = 'LocalNetPriorityMask'
                            PropertyValue = [System.UInt32] 255
                        }
                        @{
                            PropertyName  = 'TcpReceivePacketSize'
                            PropertyValue = [System.UInt32] 65536
                        }
                        @{
                            PropertyName  = 'SelfTest'
                            PropertyValue = [System.UInt32] 4294967295
                        }
                        @{
                            PropertyName  = 'XfrThrottleMultiplier'
                            PropertyValue = [System.UInt32] 10
                        }
                        @{
                            PropertyName  = 'SocketPoolSize'
                            PropertyValue = [System.UInt32] 2500
                        }
                        @{
                            PropertyName  = 'QuietRecvFaultInterval'
                            PropertyValue = [System.UInt32] 0
                        }
                        @{
                            PropertyName  = 'QuietRecvLogInterval'
                            PropertyValue = [System.UInt32] 0
                        }
                        @{
                            PropertyName  = 'SyncDsZoneSerial'
                            PropertyValue = [System.UInt32] 2
                        }
                        @{
                            PropertyName  = 'ScopeOptionValue'
                            PropertyValue = [System.UInt32] 0
                        }
                        @{
                            PropertyName  = 'VirtualizationInstanceOptionValue'
                            PropertyValue = [System.UInt32] 0
                        }
                        @{
                            PropertyName  = 'ServerLevelPluginDll'
                            PropertyValue = 'C:\dns\plugin.dll'
                        }
                        @{
                            PropertyName  = 'RootTrustAnchorsURL'
                            PropertyValue = 'https://data.iana.org/root-anchors/root-anchors.xml'
                        }
                        @{
                            PropertyName  = 'SocketPoolExcludedPortRanges'
                            PropertyValue = [System.String[]] @(5353, 5454)
                        }
                        @{
                            PropertyName  = 'LameDelegationTTL'
                            PropertyValue = '00:00:00'
                        }
                        @{
                            PropertyName  = 'MaximumSignatureScanPeriod'
                            PropertyValue = '2.00:00:00'
                        }
                        @{
                            PropertyName  = 'MaximumTrustAnchorActiveRefreshInterval'
                            PropertyValue = '15.00:00:00'
                        }
                        @{
                            PropertyName  = 'ZoneWritebackInterval'
                            PropertyValue = '00:01:00'
                        }
                    )
                }

                It 'Should return $true for property <PropertyName>' -TestCases $testCases {
                    param
                    (
                        $PropertyName,
                        $PropertyValue
                    )

                    $testTargetResourceParameters = @{
                        DnsServer     = 'dns1.company.local'
                        $PropertyName = $PropertyValue
                    }

                    Test-TargetResource @testTargetResourceParameters | Should -BeTrue
                }
            }
        }

        Describe 'DSC_DnsServerSetting\Set-TargetResource' -Tag 'Set' {
            BeforeAll {
                Mock -CommandName Assert-Module
                Mock -CommandName Set-DnsServerSetting
            }

            Context 'When the system is not in the desired state' {
                BeforeAll {
                    Mock -CommandName Get-DnsServerSetting -MockWith {
                        return New-CimInstance -ClassName 'DnsServerSetting' -Namespace 'root/Microsoft/Windows/DNS' -ClientOnly -Property @{
                            DnsServer                               = 'dns1.company.local'
                            LocalNetPriority                        = $true
                            RoundRobin                              = $true
                            RpcProtocol                             = [System.UInt32] 0
                            NameCheckFlag                           = [System.UInt32] 2
                            AutoConfigFileZones                     = [System.UInt32] 1
                            AddressAnswerLimit                      = [System.UInt32] 0
                            UpdateOptions                           = [System.UInt32] 783
                            DisableAutoReverseZone                  = $false
                            StrictFileParsing                       = $false
                            EnableDirectoryPartitions               = $false
                            XfrConnectTimeout                       = [System.UInt32] 30
                            BootMethod                              = [System.UInt32] 3
                            AllowUpdate                             = $true
                            LooseWildcarding                        = $false
                            BindSecondaries                         = $false
                            AutoCacheUpdate                         = $false
                            EnableDnsSec                            = $true
                            SendPort                                = [System.UInt32] 0
                            WriteAuthorityNS                        = $false
                            ListeningIPAddress                      = [System.String[]] @('192.168.1.10', '192.168.2.10')
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
                            EnableVersionQuery                      = [System.UInt32] 0
                            AutoCreateDelegation                    = [System.UInt32] 2
                            RemoteIPv4RankBoost                     = [System.UInt32] 5
                            RemoteIPv6RankBoost                     = [System.UInt32] 0
                            MaximumRodcRsoQueueLength               = [System.UInt32] 300
                            MaximumRodcRsoAttemptsPerCycle          = [System.UInt32] 100
                            MaxResourceRecordsInNonSecureUpdate     = [System.UInt32] 30
                            LocalNetPriorityMask                    = [System.UInt32] 255
                            TcpReceivePacketSize                    = [System.UInt32] 65536
                            SelfTest                                = [System.UInt32] 4294967295
                            XfrThrottleMultiplier                   = [System.UInt32] 10
                            SocketPoolSize                          = [System.UInt32] 2500
                            QuietRecvFaultInterval                  = [System.UInt32] 0
                            QuietRecvLogInterval                    = [System.UInt32] 0
                            SyncDsZoneSerial                        = [System.UInt32] 2
                            ScopeOptionValue                        = [System.UInt32] 0
                            VirtualizationInstanceOptionValue       = [System.UInt32] 0
                            ServerLevelPluginDll                    = 'C:\dns\plugin.dll'
                            RootTrustAnchorsURL                     = 'https://data.iana.org/root-anchors/root-anchors.xml'
                            SocketPoolExcludedPortRanges            = [System.String[]] @()
                            LameDelegationTTL                       = New-TimeSpan -Seconds 0
                            MaximumSignatureScanPeriod              = New-TimeSpan -Days 2
                            MaximumTrustAnchorActiveRefreshInterval = New-TimeSpan -Days 15
                            ZoneWritebackInterval                   = New-TimeSpan -Minutes 1
                        }
                    }

                    $testCases = @(
                        @{
                            PropertyName  = 'LocalNetPriority'
                            PropertyValue = $false
                        }
                        @{
                            PropertyName  = 'RoundRobin'
                            PropertyValue = $false
                        }
                        @{
                            PropertyName  = 'RpcProtocol'
                            PropertyValue = [System.UInt32] 1
                        }
                        @{
                            PropertyName  = 'NameCheckFlag'
                            PropertyValue = [System.UInt32] 1
                        }
                        @{
                            PropertyName  = 'AutoConfigFileZones'
                            PropertyValue = [System.UInt32] 0
                        }
                        @{
                            PropertyName  = 'AddressAnswerLimit'
                            PropertyValue = [System.UInt32] 1
                        }
                        @{
                            PropertyName  = 'UpdateOptions'
                            PropertyValue = [System.UInt32] 784
                        }
                        @{
                            PropertyName  = 'DisableAutoReverseZone'
                            PropertyValue = $true
                        }
                        @{
                            PropertyName  = 'StrictFileParsing'
                            PropertyValue = $true
                        }
                        @{
                            PropertyName  = 'EnableDirectoryPartitions'
                            PropertyValue = $true
                        }
                        @{
                            PropertyName  = 'XfrConnectTimeout'
                            PropertyValue = [System.UInt32] 40
                        }
                        @{
                            PropertyName  = 'BootMethod'
                            PropertyValue = [System.UInt32] 2
                        }
                        @{
                            PropertyName  = 'AllowUpdate'
                            PropertyValue = $false
                        }
                        @{
                            PropertyName  = 'LooseWildcarding'
                            PropertyValue = $true
                        }
                        @{
                            PropertyName  = 'BindSecondaries'
                            PropertyValue = $true
                        }
                        @{
                            PropertyName  = 'AutoCacheUpdate'
                            PropertyValue = $true
                        }
                        @{
                            PropertyName  = 'EnableDnsSec'
                            PropertyValue = $false
                        }
                        @{
                            PropertyName  = 'SendPort'
                            PropertyValue = [System.UInt32] 100
                        }
                        @{
                            PropertyName  = 'WriteAuthorityNS'
                            PropertyValue = $true
                        }
                        @{
                            PropertyName  = 'ForwardDelegations'
                            PropertyValue = $true
                        }
                        @{
                            PropertyName  = 'ListeningIPAddress'
                            PropertyValue = [System.String[]] @('fe80::e82e:70b7:f1d4:f695')
                        }
                        @{
                            PropertyName  = 'EnableIPv6'
                            PropertyValue = $false
                        }
                        @{
                            PropertyName  = 'EnableOnlineSigning'
                            PropertyValue = $false
                        }
                        @{
                            PropertyName  = 'EnableDuplicateQuerySuppression'
                            PropertyValue = $false
                        }
                        @{
                            PropertyName  = 'AllowCnameAtNs'
                            PropertyValue = $false
                        }
                        @{
                            PropertyName  = 'EnableRsoForRodc'
                            PropertyValue = $false
                        }
                        @{
                            PropertyName  = 'OpenAclOnProxyUpdates'
                            PropertyValue = $false
                        }
                        @{
                            PropertyName  = 'NoUpdateDelegations'
                            PropertyValue = $true
                        }
                        @{
                            PropertyName  = 'EnableUpdateForwarding'
                            PropertyValue = $true
                        }
                        @{
                            PropertyName  = 'EnableWinsR'
                            PropertyValue = $false
                        }
                        @{
                            PropertyName  = 'DeleteOutsideGlue'
                            PropertyValue = $true
                        }
                        @{
                            PropertyName  = 'AppendMsZoneTransferTag'
                            PropertyValue = $true
                        }
                        @{
                            PropertyName  = 'AllowReadOnlyZoneTransfer'
                            PropertyValue = $true
                        }
                        @{
                            PropertyName  = 'EnableSendErrorSuppression'
                            PropertyValue = $false
                        }
                        @{
                            PropertyName  = 'SilentlyIgnoreCnameUpdateConflicts'
                            PropertyValue = $true
                        }
                        @{
                            PropertyName  = 'EnableIQueryResponseGeneration'
                            PropertyValue = $true
                        }
                        @{
                            PropertyName  = 'AdminConfigured'
                            PropertyValue = $false
                        }
                        @{
                            PropertyName  = 'PublishAutoNet'
                            PropertyValue = $true
                        }
                        @{
                            PropertyName  = 'ReloadException'
                            PropertyValue = $true
                        }
                        @{
                            PropertyName  = 'IgnoreServerLevelPolicies'
                            PropertyValue = $true
                        }
                        @{
                            PropertyName  = 'IgnoreAllPolicies'
                            PropertyValue = $true
                        }
                        @{
                            PropertyName  = 'EnableVersionQuery'
                            PropertyValue = [System.UInt32] 1
                        }
                        @{
                            PropertyName  = 'AutoCreateDelegation'
                            PropertyValue = [System.UInt32] 1
                        }
                        @{
                            PropertyName  = 'RemoteIPv4RankBoost'
                            PropertyValue = [System.UInt32] 4
                        }
                        @{
                            PropertyName  = 'RemoteIPv6RankBoost'
                            PropertyValue = [System.UInt32] 1
                        }
                        @{
                            PropertyName  = 'MaximumRodcRsoQueueLength'
                            PropertyValue = [System.UInt32] 350
                        }
                        @{
                            PropertyName  = 'MaximumRodcRsoAttemptsPerCycle'
                            PropertyValue = [System.UInt32] 150
                        }
                        @{
                            PropertyName  = 'MaxResourceRecordsInNonSecureUpdate'
                            PropertyValue = [System.UInt32] 40
                        }
                        @{
                            PropertyName  = 'LocalNetPriorityMask'
                            PropertyValue = [System.UInt32] 254
                        }
                        @{
                            PropertyName  = 'TcpReceivePacketSize'
                            PropertyValue = [System.UInt32] 65000
                        }
                        @{
                            PropertyName  = 'SelfTest'
                            PropertyValue = [System.UInt32] 4000000000
                        }
                        @{
                            PropertyName  = 'XfrThrottleMultiplier'
                            PropertyValue = [System.UInt32] 15
                        }
                        @{
                            PropertyName  = 'SocketPoolSize'
                            PropertyValue = [System.UInt32] 3000
                        }
                        @{
                            PropertyName  = 'QuietRecvFaultInterval'
                            PropertyValue = [System.UInt32] 1
                        }
                        @{
                            PropertyName  = 'QuietRecvLogInterval'
                            PropertyValue = [System.UInt32] 1
                        }
                        @{
                            PropertyName  = 'SyncDsZoneSerial'
                            PropertyValue = [System.UInt32] 1
                        }
                        @{
                            PropertyName  = 'ScopeOptionValue'
                            PropertyValue = [System.UInt32] 1
                        }
                        @{
                            PropertyName  = 'VirtualizationInstanceOptionValue'
                            PropertyValue = [System.UInt32] 1
                        }
                        @{
                            PropertyName  = 'ServerLevelPluginDll'
                            PropertyValue = 'C:\dns\oldPlugin.dll'
                        }
                        @{
                            PropertyName  = 'RootTrustAnchorsURL'
                            PropertyValue = 'https://data.iana.org/old-root-anchors/root-anchors.xml'
                        }
                        @{
                            PropertyName  = 'SocketPoolExcludedPortRanges'
                            PropertyValue = [System.String[]] @(5353, 5454)
                        }
                        @{
                            PropertyName  = 'LameDelegationTTL'
                            PropertyValue = '00:00:01'
                        }
                        @{
                            PropertyName  = 'MaximumSignatureScanPeriod'
                            PropertyValue = '3.00:00:00'
                        }
                        @{
                            PropertyName  = 'MaximumTrustAnchorActiveRefreshInterval'
                            PropertyValue = '20.00:00:00'
                        }
                        @{
                            PropertyName  = 'ZoneWritebackInterval'
                            PropertyValue = '00:00:30'
                        }
                    )
                }

                It 'Should not throw and call the correct mock to set the property <PropertyName>' -TestCases $testCases {
                    param
                    (
                        $PropertyName,
                        $PropertyValue
                    )

                    $setTargetResourceParameters = @{
                        DnsServer     = 'dns1.company.local'
                        $PropertyName = $PropertyValue
                    }

                    { Set-TargetResource @setTargetResourceParameters } | Should -Not -Throw

                    Assert-MockCalled -CommandName Set-DnsServerSetting -Exactly -Times 1 -Scope It
                }
            }

            Context 'When the system is in the desired state' {
                BeforeAll {
                    Mock -CommandName Get-DnsServerSetting -MockWith {
                        return New-CimInstance -ClassName 'DnsServerSetting' -Namespace 'root/Microsoft/Windows/DNS' -ClientOnly -Property @{
                            DnsServer                               = 'dns1.company.local'
                            LocalNetPriority                        = $true
                            RoundRobin                              = $true
                            RpcProtocol                             = [System.UInt32] 0
                            NameCheckFlag                           = [System.UInt32] 2
                            AutoConfigFileZones                     = [System.UInt32] 1
                            AddressAnswerLimit                      = [System.UInt32] 0
                            UpdateOptions                           = [System.UInt32] 783
                            DisableAutoReverseZone                  = $false
                            StrictFileParsing                       = $false
                            EnableDirectoryPartitions               = $false
                            XfrConnectTimeout                       = [System.UInt32] 30
                            BootMethod                              = [System.UInt32] 3
                            AllowUpdate                             = $true
                            LooseWildcarding                        = $false
                            BindSecondaries                         = $false
                            AutoCacheUpdate                         = $false
                            EnableDnsSec                            = $true
                            SendPort                                = [System.UInt32] 0
                            WriteAuthorityNS                        = $false
                            ListeningIPAddress                      = [System.String[]] @('192.168.1.10', '192.168.2.10')
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
                            EnableVersionQuery                      = [System.UInt32] 0
                            AutoCreateDelegation                    = [System.UInt32] 2
                            RemoteIPv4RankBoost                     = [System.UInt32] 5
                            RemoteIPv6RankBoost                     = [System.UInt32] 0
                            MaximumRodcRsoQueueLength               = [System.UInt32] 300
                            MaximumRodcRsoAttemptsPerCycle          = [System.UInt32] 100
                            MaxResourceRecordsInNonSecureUpdate     = [System.UInt32] 30
                            LocalNetPriorityMask                    = [System.UInt32] 255
                            TcpReceivePacketSize                    = [System.UInt32] 65536
                            SelfTest                                = [System.UInt32] 4294967295
                            XfrThrottleMultiplier                   = [System.UInt32] 10
                            SocketPoolSize                          = [System.UInt32] 2500
                            QuietRecvFaultInterval                  = [System.UInt32] 0
                            QuietRecvLogInterval                    = [System.UInt32] 0
                            SyncDsZoneSerial                        = [System.UInt32] 2
                            ScopeOptionValue                        = [System.UInt32] 0
                            VirtualizationInstanceOptionValue       = [System.UInt32] 0
                            ServerLevelPluginDll                    = 'C:\dns\plugin.dll'
                            RootTrustAnchorsURL                     = 'https://data.iana.org/root-anchors/root-anchors.xml'
                            SocketPoolExcludedPortRanges            = [System.String[]] @(5353, 5454)
                            LameDelegationTTL                       = New-TimeSpan -Seconds 0
                            MaximumSignatureScanPeriod              = New-TimeSpan -Days 2
                            MaximumTrustAnchorActiveRefreshInterval = New-TimeSpan -Days 15
                            ZoneWritebackInterval                   = New-TimeSpan -Minutes 1
                        }
                    }


                    $testCases = @(
                        @{
                            PropertyName  = 'LocalNetPriority'
                            PropertyValue = $true
                        }
                        @{
                            PropertyName  = 'RoundRobin'
                            PropertyValue = $true
                        }
                        @{
                            PropertyName  = 'RpcProtocol'
                            PropertyValue = [System.UInt32] 0
                        }
                        @{
                            PropertyName  = 'NameCheckFlag'
                            PropertyValue = [System.UInt32] 2
                        }
                        @{
                            PropertyName  = 'AutoConfigFileZones'
                            PropertyValue = [System.UInt32] 1
                        }
                        @{
                            PropertyName  = 'AddressAnswerLimit'
                            PropertyValue = [System.UInt32] 0
                        }
                        @{
                            PropertyName  = 'UpdateOptions'
                            PropertyValue = [System.UInt32] 783
                        }
                        @{
                            PropertyName  = 'DisableAutoReverseZone'
                            PropertyValue = $false
                        }
                        @{
                            PropertyName  = 'StrictFileParsing'
                            PropertyValue = $false
                        }
                        @{
                            PropertyName  = 'EnableDirectoryPartitions'
                            PropertyValue = $false
                        }
                        @{
                            PropertyName  = 'XfrConnectTimeout'
                            PropertyValue = [System.UInt32] 30
                        }
                        @{
                            PropertyName  = 'BootMethod'
                            PropertyValue = [System.UInt32] 3
                        }
                        @{
                            PropertyName  = 'AllowUpdate'
                            PropertyValue = $true
                        }
                        @{
                            PropertyName  = 'LooseWildcarding'
                            PropertyValue = $false
                        }
                        @{
                            PropertyName  = 'BindSecondaries'
                            PropertyValue = $false
                        }
                        @{
                            PropertyName  = 'AutoCacheUpdate'
                            PropertyValue = $false
                        }
                        @{
                            PropertyName  = 'EnableDnsSec'
                            PropertyValue = $true
                        }
                        @{
                            PropertyName  = 'SendPort'
                            PropertyValue = [System.UInt32] 0
                        }
                        @{
                            PropertyName  = 'WriteAuthorityNS'
                            PropertyValue = $false
                        }
                        @{
                            PropertyName  = 'ForwardDelegations'
                            PropertyValue = $false
                        }
                        @{
                            PropertyName  = 'ListeningIPAddress'
                            PropertyValue = [System.String[]] @('192.168.1.10', '192.168.2.10')
                        }
                        @{
                            PropertyName  = 'EnableIPv6'
                            PropertyValue = $true
                        }
                        @{
                            PropertyName  = 'EnableOnlineSigning'
                            PropertyValue = $true
                        }
                        @{
                            PropertyName  = 'EnableDuplicateQuerySuppression'
                            PropertyValue = $true
                        }
                        @{
                            PropertyName  = 'AllowCnameAtNs'
                            PropertyValue = $true
                        }
                        @{
                            PropertyName  = 'EnableRsoForRodc'
                            PropertyValue = $true
                        }
                        @{
                            PropertyName  = 'OpenAclOnProxyUpdates'
                            PropertyValue = $true
                        }
                        @{
                            PropertyName  = 'NoUpdateDelegations'
                            PropertyValue = $false
                        }
                        @{
                            PropertyName  = 'EnableUpdateForwarding'
                            PropertyValue = $false
                        }
                        @{
                            PropertyName  = 'EnableWinsR'
                            PropertyValue = $true
                        }
                        @{
                            PropertyName  = 'DeleteOutsideGlue'
                            PropertyValue = $false
                        }
                        @{
                            PropertyName  = 'AppendMsZoneTransferTag'
                            PropertyValue = $false
                        }
                        @{
                            PropertyName  = 'AllowReadOnlyZoneTransfer'
                            PropertyValue = $false
                        }
                        @{
                            PropertyName  = 'EnableSendErrorSuppression'
                            PropertyValue = $true
                        }
                        @{
                            PropertyName  = 'SilentlyIgnoreCnameUpdateConflicts'
                            PropertyValue = $false
                        }
                        @{
                            PropertyName  = 'EnableIQueryResponseGeneration'
                            PropertyValue = $false
                        }
                        @{
                            PropertyName  = 'AdminConfigured'
                            PropertyValue = $true
                        }
                        @{
                            PropertyName  = 'PublishAutoNet'
                            PropertyValue = $false
                        }
                        @{
                            PropertyName  = 'ReloadException'
                            PropertyValue = $false
                        }
                        @{
                            PropertyName  = 'IgnoreServerLevelPolicies'
                            PropertyValue = $false
                        }
                        @{
                            PropertyName  = 'IgnoreAllPolicies'
                            PropertyValue = $false
                        }
                        @{
                            PropertyName  = 'EnableVersionQuery'
                            PropertyValue = [System.UInt32] 0
                        }
                        @{
                            PropertyName  = 'AutoCreateDelegation'
                            PropertyValue = [System.UInt32] 2
                        }
                        @{
                            PropertyName  = 'RemoteIPv4RankBoost'
                            PropertyValue = [System.UInt32] 5
                        }
                        @{
                            PropertyName  = 'RemoteIPv6RankBoost'
                            PropertyValue = [System.UInt32] 0
                        }
                        @{
                            PropertyName  = 'MaximumRodcRsoQueueLength'
                            PropertyValue = [System.UInt32] 300
                        }
                        @{
                            PropertyName  = 'MaximumRodcRsoAttemptsPerCycle'
                            PropertyValue = [System.UInt32] 100
                        }
                        @{
                            PropertyName  = 'MaxResourceRecordsInNonSecureUpdate'
                            PropertyValue = [System.UInt32] 30
                        }
                        @{
                            PropertyName  = 'LocalNetPriorityMask'
                            PropertyValue = [System.UInt32] 255
                        }
                        @{
                            PropertyName  = 'TcpReceivePacketSize'
                            PropertyValue = [System.UInt32] 65536
                        }
                        @{
                            PropertyName  = 'SelfTest'
                            PropertyValue = [System.UInt32] 4294967295
                        }
                        @{
                            PropertyName  = 'XfrThrottleMultiplier'
                            PropertyValue = [System.UInt32] 10
                        }
                        @{
                            PropertyName  = 'SocketPoolSize'
                            PropertyValue = [System.UInt32] 2500
                        }
                        @{
                            PropertyName  = 'QuietRecvFaultInterval'
                            PropertyValue = [System.UInt32] 0
                        }
                        @{
                            PropertyName  = 'QuietRecvLogInterval'
                            PropertyValue = [System.UInt32] 0
                        }
                        @{
                            PropertyName  = 'SyncDsZoneSerial'
                            PropertyValue = [System.UInt32] 2
                        }
                        @{
                            PropertyName  = 'ScopeOptionValue'
                            PropertyValue = [System.UInt32] 0
                        }
                        @{
                            PropertyName  = 'VirtualizationInstanceOptionValue'
                            PropertyValue = [System.UInt32] 0
                        }
                        @{
                            PropertyName  = 'ServerLevelPluginDll'
                            PropertyValue = 'C:\dns\plugin.dll'
                        }
                        @{
                            PropertyName  = 'RootTrustAnchorsURL'
                            PropertyValue = 'https://data.iana.org/root-anchors/root-anchors.xml'
                        }
                        @{
                            PropertyName  = 'SocketPoolExcludedPortRanges'
                            PropertyValue = [System.String[]] @(5353, 5454)
                        }
                        @{
                            PropertyName  = 'LameDelegationTTL'
                            PropertyValue = '00:00:00'
                        }
                        @{
                            PropertyName  = 'MaximumSignatureScanPeriod'
                            PropertyValue = '2.00:00:00'
                        }
                        @{
                            PropertyName  = 'MaximumTrustAnchorActiveRefreshInterval'
                            PropertyValue = '15.00:00:00'
                        }
                        @{
                            PropertyName  = 'ZoneWritebackInterval'
                            PropertyValue = '00:01:00'
                        }
                    )
                }

                It 'Should not throw and should not set the property <PropertyName>' -TestCases $testCases {
                    param
                    (
                        $PropertyName,
                        $PropertyValue
                    )

                    $setTargetResourceParameters = @{
                        DnsServer     = 'dns1.company.local'
                        $PropertyName = $PropertyValue
                    }

                    { Set-TargetResource @setTargetResourceParameters } | Should -Not -Throw

                    Assert-MockCalled -CommandName Set-DnsServerSetting -Exactly -Times 0 -Scope It
                }
            }
        }
    }
}
finally
{
    Invoke-TestCleanup
}
