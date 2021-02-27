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
        #region Pester Test Initialization
        $testParameters = @{
            DnsServer                 = 'dns1.company.local'
            AddressAnswerLimit        = 5
            AllowUpdate               = 2
            AutoCacheUpdate           = $true
            AutoConfigFileZones       = 4
            BindSecondaries           = $true
            BootMethod                = 1
            DisableAutoReverseZone    = $true
            DisjointNets              = $true
            DsPollingInterval         = 10
            DsTombstoneInterval       = 10
            EnableDirectoryPartitions = $false
            EnableDnsSec              = 0
            ForwardDelegations        = 1
            IsSlave                   = $true
            ListenAddresses           = '192.168.0.10', '192.168.0.11'
            LocalNetPriority          = $false
            LogLevel                  = 256
            LooseWildcarding          = $true
            NameCheckFlag             = 1
            RoundRobin                = $false
            RpcProtocol               = 1
            SendPort                  = 100
            StrictFileParsing         = $true
            UpdateOptions             = 700
            WriteAuthorityNS          = $true
            XfrConnectTimeout         = 15
        }

        $mockGetCimInstance = @{
            DnsServer                 = 'dns1.company.local'
            Caption                   = $null
            Description               = $null
            InstallDate               = $null
            Status                    = 'OK'
            CreationClassName         = $null
            Started                   = $true
            StartMode                 = 'Automatic'
            SystemCreationClassName   = $null
            SystemName                = $null
            AddressAnswerLimit        = 0
            AllowUpdate               = 1
            AutoCacheUpdate           = $false
            AutoConfigFileZones       = 1
            BindSecondaries           = $false
            BootMethod                = 3
            DisableAutoReverseZone    = $false
            DisjointNets              = $false
            DsAvailable               = $true
            DsPollingInterval         = 180
            DsTombstoneInterval       = 1209600
            EnableDirectoryPartitions = $true
            EnableDnsSec              = 1
            ForwardDelegations        = 0
            IsSlave                   = $false
            ListenAddresses           = $null
            LocalNetPriority          = $true
            LogLevel                  = 0
            LooseWildcarding          = $false
            NameCheckFlag             = 2
            RoundRobin                = $true
            RpcProtocol               = 5
            SendPort                  = 0
            ServerAddresses           = 'fe80::7da3:a014:6581:2cdc', '10.0.0.4'
            StrictFileParsing         = $false
            UpdateOptions             = 783
            Version                   = 629146374
            WriteAuthorityNS          = $false
            XfrConnectTimeout         = 30
            PSComputerName            = $null
        }

        $array1 = 1, 2, 3
        $array2 = 3, 2, 1
        $array3 = 1, 2, 3, 4

        $mockReadOnlyProperties = @{
            DsAvailable = $true
        }
        #endregion Pester Test Initialization

        #region Example state 1
        Describe 'DSC_DnsServerSetting\Get-TargetResource' {
            Mock -CommandName Assert-Module

            Context 'The system is not in the desired state' {
                It "Get method returns 'something'" {
                    Mock Get-CimInstance -MockWith { $mockGetCimInstance }
                    $getResult = Get-TargetResource -DnsServer 'dns1.company.local' -Verbose

                    foreach ($key in $getResult.Keys)
                    {
                        if ($null -ne $getResult[$key] -and $key -ne 'DnsServer')
                        {
                            $getResult[$key] | Should be $mockGetCimInstance[$key]
                        }

                        if ($key -eq 'DsAvailable')
                        {
                            $getResult[$key] | Should Be $mockReadOnlyProperties[$key]
                        }
                    }
                }

                It 'Get throws when CimClass is not found' {
                    $mockThrow = @{
                        Exception = @{
                            Message = 'Invalid Namespace'
                        }
                    }

                    Mock Get-CimInstance -MockWith { throw $mockThrow }

                    { Get-TargetResource -DnsServer 'dns1.company.local' -Verbose } | Should -Throw
                }
            }

            Context 'Error handling' {
                It 'Test throws when CimClass is not found' {
                    $mockThrow = @{
                        Exception = @{
                            Message = 'Invalid Namespace'
                        }
                    }

                    Mock Get-CimInstance -MockWith { throw $mockThrow }

                    { Get-TargetResource -DnsServer 'dns1.company.local' -Verbose } | Should -Throw
                }
            }
        }

        Describe 'DSC_DnsServerSetting\Test-TargetResource' {
            Mock -CommandName Assert-Module

            Context 'The system is not in the desired state' {
                $falseParameters = @{
                    DnsServer = 'dns1.company.local'
                }

                foreach ($key in $testParameters.Keys)
                {
                    if ($key -ne 'DnsServer')
                    {
                        $falseTestParameters = $falseParameters.Clone()
                        $falseTestParameters.Add($key, $testParameters[$key])

                        It "Test method returns false when testing $key" {
                            Mock Get-TargetResource -MockWith { $mockGetCimInstance }
                            Test-TargetResource @falseTestParameters -Verbose | Should -BeFalse
                        }
                    }
                }
            }

            Context 'The system is in the desired state' {
                Mock Get-TargetResource -MockWith { $mockGetCimInstance }

                $trueParameters = @{
                    DnsServer = 'dns1.company.local'
                }

                foreach ($key in $testParameters.Keys)
                {
                    if ($key -ne 'DnsServer')
                    {
                        $trueTestParameters = $trueParameters.Clone()
                        $trueTestParameters.Add($key, $mockGetCimInstance[$key])

                        It "Test method returns true when testing $key" {
                            Test-TargetResource @trueTestParameters -Verbose | Should -BeTrue
                        }
                    }
                }
            }
        }

        Describe 'DSC_DnsServerSetting\Test-TargetResource' {
            Mock -CommandName Assert-Module

            It 'Set method calls Set-CimInstance' {
                $mockCimClass = Import-Clixml -Path $PSScriptRoot\MockObjects\DnsServerClass.xml

                Mock Get-CimInstance -MockWith { $mockCimClass }
                Mock Set-CimInstance

                Set-TargetResource @testParameters -Verbose

                Assert-MockCalled Set-CimInstance -Exactly 1
            }
        }
    }
}
finally
{
    Invoke-TestCleanup
}
