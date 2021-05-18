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
                        DnsServer                        = 'dns1.company.local'
                        LocalNetPriority                 = $false
                        RoundRobin                       = $false
                        RpcProtocol                      = 1
                        NameCheckFlag                    = 2
                        AutoConfigFileZones              = 1
                        AddressAnswerLimit               = 0
                        UpdateOptions                    = 783
                        DisableAutoReverseZone           = $false
                        StrictFileParsing                = $false
                        EnableDirectoryPartitions        = $false
                        XfrConnectTimeout                = 30
                        BootMethod                       = 3
                        AllowUpdate                      = $true
                        LooseWildcarding                 = $false
                        BindSecondaries                  = $false
                        AutoCacheUpdate                  = $false
                        EnableDnsSec                     = $true
                        SendPort                         = 0
                        WriteAuthorityNS                 = $false
                        ListeningIPAddress               = @('192.168.1.10', '192.168.2.10')
                        ForwardDelegations               = $false

                        # Read-only properties
                        DsAvailable                      = $true
                        MajorVersion                     = 10
                        MinorVersion                     = 0
                        BuildNumber                      = 14393
                        IsReadOnlyDC                     = $false
                        AllIPAddress                     = @('fe80::e82e:70b7:f1d4:f695', '192.168.1.10', '192.168.2.10')
                        ForestDirectoryPartitionBaseName = 'ForestDnsZones'
                        DomainDirectoryPartitionBaseName = 'DomainDnsZones'
                        MaximumUdpPacketSize             = 4000
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

                    $getTargetResourceResult.ListeningIPAddress | Should -HaveCount 2
                    $getTargetResourceResult.ListeningIPAddress | Should -Contain '192.168.1.10'
                    $getTargetResourceResult.ListeningIPAddress | Should -Contain '192.168.2.10'

                    $getTargetResourceResult.AllIPAddress | Should -HaveCount 3
                    $getTargetResourceResult.AllIPAddress | Should -Contain 'fe80::e82e:70b7:f1d4:f695'
                    $getTargetResourceResult.AllIPAddress | Should -Contain '192.168.1.10'
                    $getTargetResourceResult.AllIPAddress | Should -Contain '192.168.2.10'
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
                            DnsServer                 = 'dns1.company.local'
                            LocalNetPriority          = $true
                            RoundRobin                = $true
                            RpcProtocol               = [System.UInt32] 0
                            NameCheckFlag             = [System.UInt32] 2
                            AutoConfigFileZones       = [System.UInt32] 1
                            AddressAnswerLimit        = [System.UInt32] 0
                            UpdateOptions             = [System.UInt32] 783
                            DisableAutoReverseZone    = $false
                            StrictFileParsing         = $false
                            EnableDirectoryPartitions = $false
                            XfrConnectTimeout         = [System.UInt32] 30
                            BootMethod                = [System.UInt32] 3
                            AllowUpdate               = $true
                            LooseWildcarding          = $false
                            BindSecondaries           = $false
                            AutoCacheUpdate           = $false
                            EnableDnsSec              = $true
                            SendPort                  = [System.UInt32] 0
                            WriteAuthorityNS          = $false
                            ListeningIPAddress        = [System.String[]] @('192.168.1.10', '192.168.2.10')
                            ForwardDelegations        = $false
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
                            DnsServer                 = 'dns1.company.local'
                            LocalNetPriority          = $true
                            RoundRobin                = $true
                            RpcProtocol               = [System.UInt32] 0
                            NameCheckFlag             = [System.UInt32] 2
                            AutoConfigFileZones       = [System.UInt32] 1
                            AddressAnswerLimit        = [System.UInt32] 0
                            UpdateOptions             = [System.UInt32] 783
                            DisableAutoReverseZone    = $false
                            StrictFileParsing         = $false
                            EnableDirectoryPartitions = $false
                            XfrConnectTimeout         = [System.UInt32] 30
                            BootMethod                = [System.UInt32] 3
                            AllowUpdate               = $true
                            LooseWildcarding          = $false
                            BindSecondaries           = $false
                            AutoCacheUpdate           = $false
                            EnableDnsSec              = $true
                            SendPort                  = [System.UInt32] 0
                            WriteAuthorityNS          = $false
                            ListeningIPAddress        = [System.String[]] @('192.168.1.10', '192.168.2.10')
                            ForwardDelegations        = $false
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
                            DnsServer                 = 'dns1.company.local'
                            LocalNetPriority          = $true
                            RoundRobin                = $true
                            RpcProtocol               = [System.UInt32] 0
                            NameCheckFlag             = [System.UInt32] 2
                            AutoConfigFileZones       = [System.UInt32] 1
                            AddressAnswerLimit        = [System.UInt32] 0
                            UpdateOptions             = [System.UInt32] 783
                            DisableAutoReverseZone    = $false
                            StrictFileParsing         = $false
                            EnableDirectoryPartitions = $false
                            XfrConnectTimeout         = [System.UInt32] 30
                            BootMethod                = [System.UInt32] 3
                            AllowUpdate               = $true
                            LooseWildcarding          = $false
                            BindSecondaries           = $false
                            AutoCacheUpdate           = $false
                            EnableDnsSec              = $true
                            SendPort                  = [System.UInt32] 0
                            WriteAuthorityNS          = $false
                            ListeningIPAddress        = [System.String[]] @('192.168.1.10', '192.168.2.10')
                            ForwardDelegations        = $false
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
                            DnsServer                 = 'dns1.company.local'
                            LocalNetPriority          = $true
                            RoundRobin                = $true
                            RpcProtocol               = [System.UInt32] 0
                            NameCheckFlag             = [System.UInt32] 2
                            AutoConfigFileZones       = [System.UInt32] 1
                            AddressAnswerLimit        = [System.UInt32] 0
                            UpdateOptions             = [System.UInt32] 783
                            DisableAutoReverseZone    = $false
                            StrictFileParsing         = $false
                            EnableDirectoryPartitions = $false
                            XfrConnectTimeout         = [System.UInt32] 30
                            BootMethod                = [System.UInt32] 3
                            AllowUpdate               = $true
                            LooseWildcarding          = $false
                            BindSecondaries           = $false
                            AutoCacheUpdate           = $false
                            EnableDnsSec              = $true
                            SendPort                  = [System.UInt32] 0
                            WriteAuthorityNS          = $false
                            ListeningIPAddress        = [System.String[]] @('192.168.1.10', '192.168.2.10')
                            ForwardDelegations        = $false
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
