$script:dscModuleName = 'DnsServerDsc'
$script:dscResourceName = 'DSC_DnsServerSettingLegacy'

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
        Describe 'DSC_DnsServerSettingLegacy\Get-TargetResource' -Tag 'Get' {
            BeforeAll {
                $mockGetCimInstance = @{
                    DnsServer            = 'dns1.company.local'
                    DisjointNets         = $false
                    NoForwarderRecursion = $false
                    LogLevel             = [System.UInt32] 0
                }

                Mock -CommandName Assert-Module
                Mock -CommandName Get-CimClassMicrosoftDnsServer -MockWith {
                    return $mockGetCimInstance
                }
            }

            Context 'When the system is in the desired state' {
                It "Should return the correct values for each property" {
                    $getTargetResourceResult = Get-TargetResource -DnsServer 'dns1.company.local'

                    $getTargetResourceResult.DisjointNets | Should -BeFalse
                    $getTargetResourceResult.NoForwarderRecursion | Should -BeFalse
                    $getTargetResourceResult.LogLevel | Should -Be 0
                }
            }
        }

        Describe 'DSC_DnsServerSettingLegacy\Test-TargetResource' -Tag 'Test' {
            BeforeAll {
                Mock -CommandName Assert-Module
            }

            Context 'When the system is not in the desired state' {
                BeforeAll {
                    Mock -CommandName Get-TargetResource -MockWith {
                        return @{
                            DnsServer            = 'dns1.company.local'
                            DisjointNets         = $true
                            NoForwarderRecursion = $true
                            LogLevel             = [System.UInt32] 5
                        }
                    }

                    $testCases = @(
                        @{
                            PropertyName  = 'DisjointNets'
                            PropertyValue = $false
                        }
                        @{
                            PropertyName  = 'NoForwarderRecursion'
                            PropertyValue = $false
                        }
                        @{
                            PropertyName  = 'LogLevel'
                            PropertyValue = [System.UInt32] 0
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
                        DnsServer = 'dns1.company.local'
                        $PropertyName = $PropertyValue
                    }

                    Test-TargetResource @testTargetResourceParameters | Should -BeFalse
                }
            }

            Context 'When the system is in the desired state' {
                BeforeAll {
                    Mock -CommandName Get-TargetResource -MockWith {
                        return @{
                            DnsServer            = 'dns1.company.local'
                            DisjointNets         = $true
                            NoForwarderRecursion = $true
                            LogLevel             = [System.UInt32] 5
                        }
                    }

                    $testCases = @(
                        @{
                            PropertyName  = 'DisjointNets'
                            PropertyValue = $true
                        }
                        @{
                            PropertyName  = 'NoForwarderRecursion'
                            PropertyValue = $true
                        }
                        @{
                            PropertyName  = 'LogLevel'
                            PropertyValue = [System.UInt32] 5
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
                        DnsServer = 'dns1.company.local'
                        $PropertyName = $PropertyValue
                    }

                    Test-TargetResource @testTargetResourceParameters | Should -BeTrue
                }
            }
        }

        # TODO: continue here

        Describe 'DSC_DnsServerSettingLegacy\Set-TargetResource' {
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
