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

Describe 'DnsServerScavenging\Get()' -Tag 'Get' {
    Context 'When the system is in the desired state' {
        BeforeAll {
            Mock -CommandName Assert-Module -ModuleName $ProjectName
            Mock -CommandName Get-DnsServerScavenging -ModuleName $ProjectName -MockWith {
                return New-CimInstance -ClassName 'DnsServerScavenging' -Namespace 'root/Microsoft/Windows/DNS' -ClientOnly -Property @{
                    ScavengingState    = $true
                    ScavengingInterval = '30.00:00:00'
                    RefreshInterval    = '30.00:00:00'
                    NoRefreshInterval  = '30.00:00:00'
                    LastScavengeTime   = '2021-01-01 00:00:00'
                }
            }
        }

        BeforeEach {
            $mockDnsServerScavengingInstance = InModuleScope $ProjectName {
                [DnsServerScavenging]::new()
            }
        }

        It 'Should have correctly instantiated the resource class' {
            $mockDnsServerScavengingInstance | Should -Not -BeNullOrEmpty
            $mockDnsServerScavengingInstance.GetType().Name | Should -Be 'DnsServerScavenging'
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

            $mockDnsServerScavengingInstance.DnsServer = $HostName

            $getResult = $mockDnsServerScavengingInstance.Get()

            $getResult.DnsServer | Should -Be $HostName
            $getResult.ScavengingState | Should -BeTrue
            $getResult.ScavengingInterval | Should -Be '30.00:00:00'
            $getResult.RefreshInterval | Should -Be '30.00:00:00'
            $getResult.NoRefreshInterval | Should -Be '30.00:00:00'

            # Returns as a DateTime type and not a string.
            $getResult.LastScavengeTime.ToString('yyyy-mm-dd HH:mm:ss') | Should -Be ([System.DateTime] '2021-01-01 00:00:00').ToString('yyyy-mm-dd HH:mm:ss')

            Assert-MockCalled -CommandName Get-DnsServerScavenging -ModuleName $ProjectName -Exactly -Times 1 -Scope It
        }
    }
}

Describe 'DnsServerScavenging\Test()' -Tag 'Test' {
    BeforeAll {
        Mock -CommandName Assert-Module -ModuleName $ProjectName
    }

    Context 'When providing an invalid interval' {
        BeforeEach {
            $mockDnsServerScavengingInstance = InModuleScope $ProjectName {
                [DnsServerScavenging]::new()
            }
        }

        Context 'When the value is a string that cannot be converted to [System.TimeSpan]' {
            It 'Should throw the correct error' {
                $mockInvalidTime = '235.a:00:00'

                $mockDnsServerScavengingInstance.ScavengingInterval = $mockInvalidTime

                $mockExpectedErrorMessage = InModuleScope $ProjectName {
                    $script:localizedData.PropertyHasWrongFormat
                }

                { $mockDnsServerScavengingInstance.Test() } | Should -Throw ($mockExpectedErrorMessage -f 'ScavengingInterval', $mockInvalidTime)
            }
        }

        Context 'When the time exceeds maximum allowed value' {
            It 'Should throw the correct error' {
                $mockInvalidTime = '365.00:00:01'

                $mockDnsServerScavengingInstance.ScavengingInterval = $mockInvalidTime

                $mockExpectedErrorMessage = InModuleScope $ProjectName {
                    $script:localizedData.TimeSpanExceedMaximumValue
                }

                { $mockDnsServerScavengingInstance.Test() } | Should -Throw ($mockExpectedErrorMessage  -f 'ScavengingInterval', $mockInvalidTime, '365.00:00:00')
            }
        }

        Context 'When the time is below minimum allowed value' {
            It 'Should throw the correct error' {
                $mockInvalidTime = '-1.00:00:00'

                $mockDnsServerScavengingInstance.ScavengingInterval = $mockInvalidTime

                $mockExpectedErrorMessage = InModuleScope $ProjectName {
                    $script:localizedData.TimeSpanBelowMinimumValue
                }

                { $mockDnsServerScavengingInstance.Test() } | Should -Throw ($mockExpectedErrorMessage -f 'ScavengingInterval', $mockInvalidTime, '00:00:00')
            }
        }
    }

    Context 'When the system is in the desired state' {
        BeforeAll {
            $mockDnsServerScavengingInstance = InModuleScope $ProjectName {
                [DnsServerScavenging]::new()
            }

            $mockDnsServerScavengingInstance.ScavengingState = $true
            $mockDnsServerScavengingInstance.ScavengingInterval = '30.00:00:00'
            $mockDnsServerScavengingInstance.RefreshInterval = '30.00:00:00'
            $mockDnsServerScavengingInstance.NoRefreshInterval = '30.00:00:00'
            $mockDnsServerScavengingInstance.LastScavengeTime = '2021-01-01 00:00:00'

            # Override Get() method
            $mockDnsServerScavengingInstance |
                Add-Member -Force -MemberType ScriptMethod -Name Get -Value {
                    return InModuleScope $ProjectName {
                        [DnsServerScavenging] @{
                            DnsServer          = 'localhost'
                            ScavengingState    = $true
                            ScavengingInterval = '30.00:00:00'
                            RefreshInterval    = '30.00:00:00'
                            NoRefreshInterval  = '30.00:00:00'
                            LastScavengeTime   = '2021-01-01 00:00:00'
                        }
                    }
                }
        }

        It 'Should return the $true' {
            $getResult = $mockDnsServerScavengingInstance.Test()

            $getResult | Should -BeTrue
        }
    }

    Context 'When the system is not in the desired state' {
        BeforeAll {
            $testCases = @(
                @{
                    PropertyName  = 'ScavengingState'
                    PropertyValue = $false
                }
                @{
                    PropertyName  = 'ScavengingInterval'
                    PropertyValue = '7.00:00:00'
                }
                @{
                    PropertyName  = 'RefreshInterval'
                    PropertyValue = '7.00:00:00'
                }
                @{
                    PropertyName  = 'NoRefreshInterval'
                    PropertyValue = '7.00:00:00'
                }
            )
        }

        BeforeEach {
            $mockDnsServerScavengingInstance = InModuleScope $ProjectName {
                [DnsServerScavenging]::new()
            }

            # Override Get() method
            $mockDnsServerScavengingInstance |
                Add-Member -Force -MemberType ScriptMethod -Name Get -Value {
                    return InModuleScope $ProjectName {
                        [DnsServerScavenging] @{
                            DnsServer          = 'localhost'
                            ScavengingState    = $true
                            ScavengingInterval = '30.00:00:00'
                            RefreshInterval    = '30.00:00:00'
                            NoRefreshInterval  = '30.00:00:00'
                            LastScavengeTime   = '2021-01-01 00:00:00'
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

            $mockDnsServerScavengingInstance.$PropertyName = $PropertyValue

            $getResult = $mockDnsServerScavengingInstance.Test()

            $getResult | Should -BeFalse
        }
    }
}

Describe 'DnsServerScavenging\Set()' -Tag 'Set' {
    BeforeAll {
        Mock -CommandName Assert-Module -ModuleName $ProjectName
    }

    Context 'When providing an invalid interval' {
        BeforeEach {
            $mockDnsServerScavengingInstance = InModuleScope $ProjectName {
                [DnsServerScavenging]::new()
            }
        }

        Context 'When the value is a string that cannot be converted to [System.TimeSpan]' {
            It 'Should throw the correct error' {
                $mockInvalidTime = '235.a:00:00'

                $mockDnsServerScavengingInstance.ScavengingInterval = $mockInvalidTime

                $mockExpectedErrorMessage = InModuleScope $ProjectName {
                    $script:localizedData.PropertyHasWrongFormat
                }

                { $mockDnsServerScavengingInstance.Test() } | Should -Throw ($mockExpectedErrorMessage -f 'ScavengingInterval', $mockInvalidTime)
            }
        }

        Context 'When the time exceeds maximum allowed value' {
            It 'Should throw the correct error' {
                $mockInvalidTime = '365.00:00:01'

                $mockDnsServerScavengingInstance.ScavengingInterval = $mockInvalidTime

                $mockExpectedErrorMessage = InModuleScope $ProjectName {
                    $script:localizedData.TimeSpanExceedMaximumValue
                }

                { $mockDnsServerScavengingInstance.Test() } | Should -Throw ($mockExpectedErrorMessage  -f 'ScavengingInterval', $mockInvalidTime, '365.00:00:00')
            }
        }

        Context 'When the time is below minimum allowed value' {
            It 'Should throw the correct error' {
                $mockInvalidTime = '-1.00:00:00'

                $mockDnsServerScavengingInstance.ScavengingInterval = $mockInvalidTime

                $mockExpectedErrorMessage = InModuleScope $ProjectName {
                    $script:localizedData.TimeSpanBelowMinimumValue
                }

                { $mockDnsServerScavengingInstance.Test() } | Should -Throw ($mockExpectedErrorMessage -f 'ScavengingInterval', $mockInvalidTime, '00:00:00')
            }
        }
    }

    Context 'When the system is in the desired state' {
        BeforeAll {
            Mock -CommandName Set-DnsServerScavenging -ModuleName $ProjectName

            $testCases = @(
                @{
                    PropertyName  = 'ScavengingState'
                    PropertyValue = $true
                }
                @{
                    PropertyName  = 'ScavengingInterval'
                    PropertyValue = '30.00:00:00'
                }
                @{
                    PropertyName  = 'RefreshInterval'
                    PropertyValue = '30.00:00:00'
                }
                @{
                    PropertyName  = 'NoRefreshInterval'
                    PropertyValue = '30.00:00:00'
                }
            )
        }

        BeforeEach {
            $mockDnsServerScavengingInstance = InModuleScope $ProjectName {
                [DnsServerScavenging]::new()
            }

            $mockDnsServerScavengingInstance.DnsServer = 'localhost'

            # Override Get() method
            $mockDnsServerScavengingInstance |
                Add-Member -Force -MemberType ScriptMethod -Name Get -Value {
                    return InModuleScope $ProjectName {
                        [DnsServerScavenging] @{
                            DnsServer          = 'localhost'
                            ScavengingState    = $true
                            ScavengingInterval = '30.00:00:00'
                            RefreshInterval    = '30.00:00:00'
                            NoRefreshInterval  = '30.00:00:00'
                            LastScavengeTime   = '2021-01-01 00:00:00'
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

            $mockDnsServerScavengingInstance.$PropertyName = $PropertyValue

            { $mockDnsServerScavengingInstance.Set() } | Should -Not -Throw

            Assert-MockCalled -CommandName Set-DnsServerScavenging -ModuleName $ProjectName -Exactly -Times 0 -Scope It
        }
    }

    Context 'When the system is not in the desired state' {
        BeforeAll {
            Mock -CommandName Set-DnsServerScavenging -ModuleName $ProjectName

            $testCases = @(
                @{
                    PropertyName  = 'ScavengingState'
                    PropertyValue = $false
                }
                @{
                    PropertyName  = 'ScavengingInterval'
                    PropertyValue = '7.00:00:00'
                }
                @{
                    PropertyName  = 'RefreshInterval'
                    PropertyValue = '7.00:00:00'
                }
                @{
                    PropertyName  = 'NoRefreshInterval'
                    PropertyValue = '7.00:00:00'
                }
            )
        }

        BeforeEach {
            $mockDnsServerScavengingInstance = InModuleScope $ProjectName {
                [DnsServerScavenging]::new()
            }

            # Override Get() method
            $mockDnsServerScavengingInstance |
                Add-Member -Force -MemberType ScriptMethod -Name Get -Value {
                    return InModuleScope $ProjectName {
                        [DnsServerScavenging] @{
                            DnsServer          = 'localhost'
                            ScavengingState    = $true
                            ScavengingInterval = '30.00:00:00'
                            RefreshInterval    = '30.00:00:00'
                            NoRefreshInterval  = '30.00:00:00'
                            LastScavengeTime   = '2021-01-01 00:00:00'
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

                $mockDnsServerScavengingInstance.DnsServer = 'localhost'
                $mockDnsServerScavengingInstance.$PropertyName = $PropertyValue

                { $mockDnsServerScavengingInstance.Set() } | Should -Not -Throw

                Assert-MockCalled -CommandName Set-DnsServerScavenging -ModuleName $ProjectName -Exactly -Times 1 -Scope It
            }
        }

        Context 'When parameter DnsServer is set to ''dns.company.local''' {
            It 'Should set the desired value for property ''<PropertyName>''' -TestCases $testCases {
                param
                (
                    $PropertyName,
                    $PropertyValue
                )

                $mockDnsServerScavengingInstance.DnsServer = 'dns.company.local'
                $mockDnsServerScavengingInstance.$PropertyName = $PropertyValue

                { $mockDnsServerScavengingInstance.Set() } | Should -Not -Throw

                Assert-MockCalled -CommandName Set-DnsServerScavenging -ModuleName $ProjectName -Exactly -Times 1 -Scope It
            }
        }
    }
}
