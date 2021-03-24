$ProjectPath = "$PSScriptRoot\..\..\.." | Convert-Path
$ProjectName = (
    Get-ChildItem $ProjectPath\*\*.psd1 | Where-Object -FilterScript {
        ($_.Directory.Name -match 'source|src' -or $_.Directory.Name -eq $_.BaseName) -and
        $(
            try
            {
                Test-ModuleManifest $_.FullName -ErrorAction Stop
            }
            catch
            {
                $false
            }
        )
    }
).BaseName

Import-Module $ProjectName

Get-Module -Name 'DnsServer' -All | Remove-Module -Force
Import-Module -Name "$PSScriptRoot\..\Stubs\DnsServer.psm1"

Describe 'DnsServerEDns\Get()' -Tag 'Get' {
    Context 'When the system is in the desired state' {
        BeforeAll {
            Mock -CommandName Assert-Module -ModuleName $ProjectName
            Mock -CommandName Get-DnsServerEDns -ModuleName $ProjectName -MockWith {
                return New-CimInstance -ClassName 'DnsServerEDns' -Namespace 'root/Microsoft/Windows/DNS' -ClientOnly -Property @{
                    CacheTimeout    = '0.00:15:00'
                    EnableProbes    = $true
                    EnableReception = $true
                }
            }
        }

        BeforeEach {
            $mockDnsServerEDnsInstance = InModuleScope $ProjectName {
                [DnsServerEDns]::new()
            }
        }

        It 'Should have correctly instantiated the resource class' {
            $mockDnsServerEDnsInstance | Should -Not -BeNullOrEmpty
            $mockDnsServerEDnsInstance.GetType().Name | Should -Be 'DnsServerEDns'
        }

        It 'Should return the correct values for the properties when DnsServer is set to ''<HostName>''' -TestCases @(
            @{
                HostName = 'localhost'
            }
            @{
                HostName = 'dns.company.local'
            }
        ) {
            param
            (
                $HostName
            )

            $mockDnsServerEDnsInstance.DnsServer = $HostName

            $getResult = $mockDnsServerEDnsInstance.Get()

            $getResult.DnsServer | Should -Be $HostName
            $getResult.EnableProbes | Should -BeTrue
            $getResult.EnableReception | Should -BeTrue
            $getResult.CacheTimeout | Should -Be '0.00:15:00'

            Assert-MockCalled -CommandName Get-DnsServerEDns -ModuleName $ProjectName -Exactly -Times 1 -Scope It
        }
    }
}

Describe 'DnsServerEDns\Test()' -Tag 'Test' {
    BeforeAll {
        Mock -CommandName Assert-Module -ModuleName $ProjectName
    }

    Context 'When providing an invalid interval' {
        BeforeEach {
            $mockDnsServerEDnsInstance = InModuleScope $ProjectName {
                [DnsServerEDns]::new()
            }
        }

        Context 'When the value is a string that cannot be converted to [System.TimeSpan]' {
            It 'Should throw the correct error' {
                $mockInvalidTime = '235.a:00:00'

                $mockDnsServerEDnsInstance.CacheTimeout = $mockInvalidTime

                $mockExpectedErrorMessage = InModuleScope $ProjectName {
                    $script:localizedData.PropertyHasWrongFormat
                }

                { $mockDnsServerEDnsInstance.Test() } | Should -Throw ($mockExpectedErrorMessage -f 'CacheTimeout', $mockInvalidTime)
            }
        }

        Context 'When the time is below minimum allowed value' {
            It 'Should throw the correct error' {
                $mockInvalidTime = '-1.00:00:00'

                $mockDnsServerEDnsInstance.CacheTimeout = $mockInvalidTime

                $mockExpectedErrorMessage = InModuleScope $ProjectName {
                    $script:localizedData.TimeSpanBelowMinimumValue
                }

                { $mockDnsServerEDnsInstance.Test() } | Should -Throw ($mockExpectedErrorMessage -f 'CacheTimeout', $mockInvalidTime, '00:00:00')
            }
        }
    }

    Context 'When the system is in the desired state' {
        BeforeAll {
            $mockDnsServerEDnsInstance = InModuleScope $ProjectName {
                [DnsServerEDns]::new()
            }

            $mockDnsServerEDnsInstance.EnableReception = $true
            $mockDnsServerEDnsInstance.EnableProbes = $true
            $mockDnsServerEDnsInstance.CacheTimeout = '0.00:15:00'

            # Override Get() method
            $mockDnsServerEDnsInstance |
                Add-Member -Force -MemberType ScriptMethod -Name Get -Value {
                    return InModuleScope $ProjectName {
                        [DnsServerEDns] @{
                            DnsServer       = 'localhost'
                            EnableReception = $true
                            EnableProbes    = $true
                            CacheTimeout    = '0.00:15:00'
                        }
                    }
                }
        }

        It 'Should return the $true' {
            $getResult = $mockDnsServerEDnsInstance.Test()

            $getResult | Should -BeTrue
        }
    }

    Context 'When the system is not in the desired state' {
        BeforeAll {
            $testCases = @(
                @{
                    PropertyName  = 'EnableProbes'
                    PropertyValue = $false
                }
                @{
                    PropertyName  = 'EnableReception'
                    PropertyValue = $false
                }
                @{
                    PropertyName  = 'CacheTimeout'
                    PropertyValue = '0.00:30:00'
                }
            )
        }

        BeforeEach {
            $mockDnsServerEDnsInstance = InModuleScope $ProjectName {
                [DnsServerEDns]::new()
            }

            # Override Get() method
            $mockDnsServerEDnsInstance |
                Add-Member -Force -MemberType ScriptMethod -Name Get -Value {
                    return InModuleScope $ProjectName {
                        [DnsServerEDns] @{
                            DnsServer       = 'localhost'
                            EnableReception = $true
                            EnableProbes    = $true
                            CacheTimeout    = '0.00:15:00'
                        }
                    }
                }
        }

        It 'Should return the $false when property <PropertyName> is not in desired state' -TestCases $testCases {
            param
            (
                $PropertyName,
                $PropertyValue
            )

            $mockDnsServerEDnsInstance.$PropertyName = $PropertyValue

            $getResult = $mockDnsServerEDnsInstance.Test()

            $getResult | Should -BeFalse
        }
    }
}

Describe 'DnsServerEDns\Set()' -Tag 'Set' {
    BeforeAll {
        Mock -CommandName Assert-Module -ModuleName $ProjectName
    }

    Context 'When providing an invalid interval' {
        BeforeEach {
            $mockDnsServerEDnsInstance = InModuleScope $ProjectName {
                [DnsServerEDns]::new()
            }
        }

        Context 'When the value is a string that cannot be converted to [System.TimeSpan]' {
            It 'Should throw the correct error' {
                $mockInvalidTime = '235.a:00:00'

                $mockDnsServerEDnsInstance.CacheTimeout = $mockInvalidTime

                $mockExpectedErrorMessage = InModuleScope $ProjectName {
                    $script:localizedData.PropertyHasWrongFormat
                }

                { $mockDnsServerEDnsInstance.Test() } | Should -Throw ($mockExpectedErrorMessage -f 'CacheTimeout', $mockInvalidTime)
            }
        }

        Context 'When the time is below minimum allowed value' {
            It 'Should throw the correct error' {
                $mockInvalidTime = '-1.00:00:00'

                $mockDnsServerEDnsInstance.CacheTimeout = $mockInvalidTime

                $mockExpectedErrorMessage = InModuleScope $ProjectName {
                    $script:localizedData.TimeSpanBelowMinimumValue
                }

                { $mockDnsServerEDnsInstance.Test() } | Should -Throw ($mockExpectedErrorMessage -f 'CacheTimeout', $mockInvalidTime, '00:00:00')
            }
        }
    }

    Context 'When the system is in the desired state' {
        BeforeAll {
            Mock -CommandName Set-DnsServerEDns -ModuleName $ProjectName

            $testCases = @(
                @{
                    PropertyName  = 'EnableProbes'
                    PropertyValue = $true
                }
                @{
                    PropertyName  = 'EnableReception'
                    PropertyValue = $true
                }
                @{
                    PropertyName  = 'CacheTimeout'
                    PropertyValue = '0.00:15:00'
                }
            )
        }

        BeforeEach {
            $mockDnsServerEDnsInstance = InModuleScope $ProjectName {
                [DnsServerEDns]::new()
            }

            $mockDnsServerEDnsInstance.DnsServer = 'localhost'

            # Override Get() method
            $mockDnsServerEDnsInstance |
                Add-Member -Force -MemberType ScriptMethod -Name Get -Value {
                    return InModuleScope $ProjectName {
                        [DnsServerEDns] @{
                            DnsServer       = 'localhost'
                            EnableReception = $true
                            EnableProbes    = $true
                            CacheTimeout    = '0.00:15:00'
                        }
                    }
                }
        }

        It 'Should not call any mock to set a value for property ''<PropertyName>''' -TestCases $testCases {
            param
            (
                $PropertyName,
                $PropertyValue
            )

            $mockDnsServerEDnsInstance.$PropertyName = $PropertyValue

            { $mockDnsServerEDnsInstance.Set() } | Should -Not -Throw

            Assert-MockCalled -CommandName Set-DnsServerEDns -ModuleName $ProjectName -Exactly -Times 0 -Scope It
        }
    }

    Context 'When the system is not in the desired state' {
        BeforeAll {
            Mock -CommandName Set-DnsServerEDns -ModuleName $ProjectName

            $testCases = @(
                @{
                    PropertyName  = 'EnableProbes'
                    PropertyValue = $false
                }
                @{
                    PropertyName  = 'EnableReception'
                    PropertyValue = $false
                }
                @{
                    PropertyName  = 'CacheTimeout'
                    PropertyValue = '0.00:30:00'
                }
            )
        }

        BeforeEach {
            $mockDnsServerEDnsInstance = InModuleScope $ProjectName {
                [DnsServerEDns]::new()
            }

            # Override Get() method
            $mockDnsServerEDnsInstance |
                Add-Member -Force -MemberType ScriptMethod -Name Get -Value {
                    return InModuleScope $ProjectName {
                        [DnsServerEDns] @{
                            DnsServer       = 'localhost'
                            EnableReception = $true
                            EnableProbes    = $true
                            CacheTimeout    = '0.00:15:00'
                        }
                    }
                }
        }

        Context 'When parameter DnsServer is set to ''localhost''' {
            It 'Should set the desired value for property ''<PropertyName>''' -TestCases $testCases {
                param
                (
                    $PropertyName,
                    $PropertyValue
                )

                $mockDnsServerEDnsInstance.DnsServer = 'localhost'
                $mockDnsServerEDnsInstance.$PropertyName = $PropertyValue

                { $mockDnsServerEDnsInstance.Set() } | Should -Not -Throw

                Assert-MockCalled -CommandName Set-DnsServerEDns -ModuleName $ProjectName -Exactly -Times 1 -Scope It
            }
        }

        Context 'When parameter DnsServer is set to ''dns.company.local''' {
            It 'Should set the desired value for property ''<PropertyName>''' -TestCases $testCases {
                param
                (
                    $PropertyName,
                    $PropertyValue
                )

                $mockDnsServerEDnsInstance.DnsServer = 'dns.company.local'
                $mockDnsServerEDnsInstance.$PropertyName = $PropertyValue

                { $mockDnsServerEDnsInstance.Set() } | Should -Not -Throw

                Assert-MockCalled -CommandName Set-DnsServerEDns -ModuleName $ProjectName -Exactly -Times 1 -Scope It
            }
        }
    }
}
