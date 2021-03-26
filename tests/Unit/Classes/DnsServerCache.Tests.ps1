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

Describe 'DnsServerCache\Get()' -Tag 'Get' {
    Context 'When the system is in the desired state' {
        BeforeAll {
            Mock -CommandName Assert-Module -ModuleName $ProjectName
            Mock -CommandName Get-DnsServerCache -ModuleName $ProjectName -MockWith {
                return New-CimInstance -ClassName 'DnsServerCache' -Namespace 'root/Microsoft/Windows/DNS' -ClientOnly -Property @{
                    IgnorePolicies                   = $true
                    LockingPercent                   = 100
                    MaxKBSize                        = 0
                    MaxNegativeTtl                   = '00:15:00'
                    MaxTtl                           = '1.00:00:00'
                    EnablePollutionProtection        = $true
                    StoreEmptyAuthenticationResponse = $true
                }
            }
        }

        BeforeEach {
            $mockDnsServerCacheInstance = InModuleScope $ProjectName {
                [DnsServerCache]::new()
            }
        }

        It 'Should have correctly instantiated the resource class' {
            $mockDnsServerCacheInstance | Should -Not -BeNullOrEmpty
            $mockDnsServerCacheInstance.GetType().Name | Should -Be 'DnsServerCache'
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

            $mockDnsServerCacheInstance.DnsServer = $HostName

            $getResult = $mockDnsServerCacheInstance.Get()

            $getResult.DnsServer | Should -Be $HostName
            $getResult.IgnorePolicies | Should -BeTrue
            $getResult.LockingPercent | Should -Be 100
            $getResult.MaxKBSize | Should -Be 0
            $getResult.EnablePollutionProtection | Should -BeTrue
            $getResult.StoreEmptyAuthenticationResponse | Should -BeTrue
            $getResult.MaxNegativeTtl | Should -Be '00:15:00'
            $getResult.MaxTtl | Should -Be '1.00:00:00'

            Assert-MockCalled -CommandName Get-DnsServerCache -ModuleName $ProjectName -Exactly -Times 1 -Scope It
        }
    }
}

Describe 'DnsServerCache\Test()' -Tag 'Test' {
    BeforeAll {
        Mock -CommandName Assert-Module -ModuleName $ProjectName
    }

    Context 'When providing an invalid interval' {
        BeforeEach {
            $mockDnsServerCacheInstance = InModuleScope $ProjectName {
                [DnsServerCache]::new()
            }
        }

        Context 'When providing a invalid value for the property MaxTtl' {
            Context 'When the value is a string that cannot be converted to [System.TimeSpan]' {
                It 'Should throw the correct error' {
                    $mockInvalidTime = '235.a:00:00'

                    $mockDnsServerCacheInstance.MaxTtl = $mockInvalidTime

                    $mockExpectedErrorMessage = InModuleScope $ProjectName {
                        $script:localizedData.PropertyHasWrongFormat
                    }

                    { $mockDnsServerCacheInstance.Test() } | Should -Throw ($mockExpectedErrorMessage -f 'MaxTtl', $mockInvalidTime)
                }
            }

            Context 'When the time exceeds maximum allowed value' {
                It 'Should throw the correct error' {
                    $mockInvalidTime = '31.00:00:00'

                    $mockDnsServerCacheInstance.MaxTtl = $mockInvalidTime

                    $mockExpectedErrorMessage = InModuleScope $ProjectName {
                        $script:localizedData.TimeSpanExceedMaximumValue
                    }

                    { $mockDnsServerCacheInstance.Test() } | Should -Throw ($mockExpectedErrorMessage -f 'MaxTtl', $mockInvalidTime, '30.00:00:00')
                }
            }

            Context 'When the time is below minimum allowed value' {
                It 'Should throw the correct error' {
                    $mockInvalidTime = '-1.00:00:00'

                    $mockDnsServerCacheInstance.MaxTtl = $mockInvalidTime

                    $mockExpectedErrorMessage = InModuleScope $ProjectName {
                        $script:localizedData.TimeSpanBelowMinimumValue
                    }

                    { $mockDnsServerCacheInstance.Test() } | Should -Throw ($mockExpectedErrorMessage -f 'MaxTtl', $mockInvalidTime, '00:00:00')
                }
            }
        }

        Context 'When providing a invalid value for the property MaxNegativeTtl' {
            Context 'When the value is a string that cannot be converted to [System.TimeSpan]' {
                It 'Should throw the correct error' {
                    $mockInvalidTime = '235.a:00:00'

                    $mockDnsServerCacheInstance.MaxNegativeTtl = $mockInvalidTime

                    $mockExpectedErrorMessage = InModuleScope $ProjectName {
                        $script:localizedData.PropertyHasWrongFormat
                    }

                    { $mockDnsServerCacheInstance.Test() } | Should -Throw ($mockExpectedErrorMessage -f 'MaxNegativeTtl', $mockInvalidTime)
                }
            }

            Context 'When the time exceeds maximum allowed value' {
                It 'Should throw the correct error' {
                    $mockInvalidTime = '31.00:00:00'

                    $mockDnsServerCacheInstance.MaxNegativeTtl = $mockInvalidTime

                    $mockExpectedErrorMessage = InModuleScope $ProjectName {
                        $script:localizedData.TimeSpanExceedMaximumValue
                    }

                    { $mockDnsServerCacheInstance.Test() } | Should -Throw ($mockExpectedErrorMessage -f 'MaxNegativeTtl', $mockInvalidTime, '30.00:00:00')
                }
            }

            Context 'When the time is below minimum allowed value' {
                It 'Should throw the correct error' {
                    $mockInvalidTime = '00:00:00'

                    $mockDnsServerCacheInstance.MaxNegativeTtl = $mockInvalidTime

                    $mockExpectedErrorMessage = InModuleScope $ProjectName {
                        $script:localizedData.TimeSpanBelowMinimumValue
                    }

                    { $mockDnsServerCacheInstance.Test() } | Should -Throw ($mockExpectedErrorMessage -f 'MaxNegativeTtl', $mockInvalidTime, '00:00:01')
                }
            }
        }
    }

    Context 'When the system is in the desired state' {
        BeforeAll {
            $mockDnsServerCacheInstance = InModuleScope $ProjectName {
                [DnsServerCache]::new()
            }

            $mockDnsServerCacheInstance.IgnorePolicies = $true
            $mockDnsServerCacheInstance.LockingPercent = 100
            $mockDnsServerCacheInstance.MaxKBSize = 0
            $mockDnsServerCacheInstance.MaxNegativeTtl = '00:15:00'
            $mockDnsServerCacheInstance.MaxTtl = '1.00:00:00'
            $mockDnsServerCacheInstance.EnablePollutionProtection = $true
            $mockDnsServerCacheInstance.StoreEmptyAuthenticationResponse = $true

            # Override Get() method
            $mockDnsServerCacheInstance |
                Add-Member -Force -MemberType ScriptMethod -Name Get -Value {
                    return InModuleScope $ProjectName {
                        [DnsServerCache] @{
                            DnsServer                        = 'localhost'
                            IgnorePolicies                   = $true
                            LockingPercent                   = 100
                            MaxKBSize                        = 0
                            MaxNegativeTtl                   = '00:15:00'
                            MaxTtl                           = '1.00:00:00'
                            EnablePollutionProtection        = $true
                            StoreEmptyAuthenticationResponse = $true
                        }
                    }
                }
        }

        It 'Should return the $true' {
            $getResult = $mockDnsServerCacheInstance.Test()

            $getResult | Should -BeTrue
        }
    }

    Context 'When the system is not in the desired state' {
        BeforeAll {
            $testCases = @(
                @{
                    PropertyName  = 'IgnorePolicies'
                    PropertyValue = $false
                }
                @{
                    PropertyName  = 'LockingPercent'
                    PropertyValue = 80
                }
                @{
                    PropertyName  = 'MaxKBSize'
                    PropertyValue = '1000'
                }
                @{
                    PropertyName  = 'MaxNegativeTtl'
                    PropertyValue = '00:30:00'
                }
                @{
                    PropertyName  = 'MaxTtl'
                    PropertyValue = '3.00:00:00'
                }
                @{
                    PropertyName  = 'EnablePollutionProtection'
                    PropertyValue = $false
                }
                @{
                    PropertyName  = 'StoreEmptyAuthenticationResponse'
                    PropertyValue = $false
                }
            )
        }

        BeforeEach {
            $mockDnsServerCacheInstance = InModuleScope $ProjectName {
                [DnsServerCache]::new()
            }

            # Override Get() method
            $mockDnsServerCacheInstance |
                Add-Member -Force -MemberType ScriptMethod -Name Get -Value {
                    return InModuleScope $ProjectName {
                        [DnsServerCache] @{
                            DnsServer                        = 'localhost'
                            IgnorePolicies                   = $true
                            LockingPercent                   = 100
                            MaxKBSize                        = 0
                            MaxNegativeTtl                   = '00:15:00'
                            MaxTtl                           = '1.00:00:00'
                            EnablePollutionProtection        = $true
                            StoreEmptyAuthenticationResponse = $true
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

            $mockDnsServerCacheInstance.$PropertyName = $PropertyValue

            $getResult = $mockDnsServerCacheInstance.Test()

            $getResult | Should -BeFalse
        }
    }
}

Describe 'DnsServerCache\Set()' -Tag 'Set' {
    BeforeAll {
        Mock -CommandName Assert-Module -ModuleName $ProjectName
    }

    Context 'When providing an invalid interval' {
        BeforeEach {
            $mockDnsServerCacheInstance = InModuleScope $ProjectName {
                [DnsServerCache]::new()
            }
        }

        Context 'When providing a invalid value for the property MaxTtl' {
            Context 'When the value is a string that cannot be converted to [System.TimeSpan]' {
                It 'Should throw the correct error' {
                    $mockInvalidTime = '235.a:00:00'

                    $mockDnsServerCacheInstance.MaxTtl = $mockInvalidTime

                    $mockExpectedErrorMessage = InModuleScope $ProjectName {
                        $script:localizedData.PropertyHasWrongFormat
                    }

                    { $mockDnsServerCacheInstance.Test() } | Should -Throw ($mockExpectedErrorMessage -f 'MaxTtl', $mockInvalidTime)
                }
            }

            Context 'When the time exceeds maximum allowed value' {
                It 'Should throw the correct error' {
                    $mockInvalidTime = '31.00:00:00'

                    $mockDnsServerCacheInstance.MaxTtl = $mockInvalidTime

                    $mockExpectedErrorMessage = InModuleScope $ProjectName {
                        $script:localizedData.TimeSpanExceedMaximumValue
                    }

                    { $mockDnsServerCacheInstance.Test() } | Should -Throw ($mockExpectedErrorMessage -f 'MaxTtl', $mockInvalidTime, '30.00:00:00')
                }
            }

            Context 'When the time is below minimum allowed value' {
                It 'Should throw the correct error' {
                    $mockInvalidTime = '-1.00:00:00'

                    $mockDnsServerCacheInstance.MaxTtl = $mockInvalidTime

                    $mockExpectedErrorMessage = InModuleScope $ProjectName {
                        $script:localizedData.TimeSpanBelowMinimumValue
                    }

                    { $mockDnsServerCacheInstance.Test() } | Should -Throw ($mockExpectedErrorMessage -f 'MaxTtl', $mockInvalidTime, '00:00:00')
                }
            }
        }

        Context 'When providing a invalid value for the property MaxNegativeTtl' {
            Context 'When the value is a string that cannot be converted to [System.TimeSpan]' {
                It 'Should throw the correct error' {
                    $mockInvalidTime = '235.a:00:00'

                    $mockDnsServerCacheInstance.MaxNegativeTtl = $mockInvalidTime

                    $mockExpectedErrorMessage = InModuleScope $ProjectName {
                        $script:localizedData.PropertyHasWrongFormat
                    }

                    { $mockDnsServerCacheInstance.Test() } | Should -Throw ($mockExpectedErrorMessage -f 'MaxNegativeTtl', $mockInvalidTime)
                }
            }

            Context 'When the time exceeds maximum allowed value' {
                It 'Should throw the correct error' {
                    $mockInvalidTime = '31.00:00:00'

                    $mockDnsServerCacheInstance.MaxNegativeTtl = $mockInvalidTime

                    $mockExpectedErrorMessage = InModuleScope $ProjectName {
                        $script:localizedData.TimeSpanExceedMaximumValue
                    }

                    { $mockDnsServerCacheInstance.Test() } | Should -Throw ($mockExpectedErrorMessage -f 'MaxNegativeTtl', $mockInvalidTime, '30.00:00:00')
                }
            }

            Context 'When the time is below minimum allowed value' {
                It 'Should throw the correct error' {
                    $mockInvalidTime = '00:00:00'

                    $mockDnsServerCacheInstance.MaxNegativeTtl = $mockInvalidTime

                    $mockExpectedErrorMessage = InModuleScope $ProjectName {
                        $script:localizedData.TimeSpanBelowMinimumValue
                    }

                    { $mockDnsServerCacheInstance.Test() } | Should -Throw ($mockExpectedErrorMessage -f 'MaxNegativeTtl', $mockInvalidTime, '00:00:01')
                }
            }
        }
    }

    Context 'When the system is in the desired state' {
        BeforeAll {
            Mock -CommandName Set-DnsServerCache -ModuleName $ProjectName

            $testCases = @(
                @{
                    PropertyName  = 'IgnorePolicies'
                    PropertyValue = $true
                }
                @{
                    PropertyName  = 'LockingPercent'
                    PropertyValue = 100
                }
                @{
                    PropertyName  = 'MaxKBSize'
                    PropertyValue = '0'
                }
                @{
                    PropertyName  = 'MaxNegativeTtl'
                    PropertyValue = '00:15:00'
                }
                @{
                    PropertyName  = 'MaxTtl'
                    PropertyValue = '1.00:00:00'
                }
                @{
                    PropertyName  = 'EnablePollutionProtection'
                    PropertyValue = $true
                }
                @{
                    PropertyName  = 'StoreEmptyAuthenticationResponse'
                    PropertyValue = $true
                }
            )
        }

        BeforeEach {
            $mockDnsServerCacheInstance = InModuleScope $ProjectName {
                [DnsServerCache]::new()
            }

            $mockDnsServerCacheInstance.DnsServer = 'localhost'

            # Override Get() method
            $mockDnsServerCacheInstance |
                Add-Member -Force -MemberType ScriptMethod -Name Get -Value {
                    return InModuleScope $ProjectName {
                        [DnsServerCache] @{
                            DnsServer                        = 'localhost'
                            IgnorePolicies                   = $true
                            LockingPercent                   = 100
                            MaxKBSize                        = 0
                            MaxNegativeTtl                   = '00:15:00'
                            MaxTtl                           = '1.00:00:00'
                            EnablePollutionProtection        = $true
                            StoreEmptyAuthenticationResponse = $true
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

            $mockDnsServerCacheInstance.$PropertyName = $PropertyValue

            { $mockDnsServerCacheInstance.Set() } | Should -Not -Throw

            Assert-MockCalled -CommandName Set-DnsServerCache -ModuleName $ProjectName -Exactly -Times 0 -Scope It
        }
    }

    Context 'When the system is not in the desired state' {
        BeforeAll {
            Mock -CommandName Set-DnsServerCache -ModuleName $ProjectName

            $testCases = @(
                @{
                    PropertyName  = 'IgnorePolicies'
                    PropertyValue = $false
                }
                @{
                    PropertyName  = 'LockingPercent'
                    PropertyValue = 80
                }
                @{
                    PropertyName  = 'MaxKBSize'
                    PropertyValue = '1000'
                }
                @{
                    PropertyName  = 'MaxNegativeTtl'
                    PropertyValue = '00:30:00'
                }
                @{
                    PropertyName  = 'MaxTtl'
                    PropertyValue = '3.00:00:00'
                }
                @{
                    PropertyName  = 'EnablePollutionProtection'
                    PropertyValue = $false
                }
                @{
                    PropertyName  = 'StoreEmptyAuthenticationResponse'
                    PropertyValue = $false
                }
            )
        }

        BeforeEach {
            $mockDnsServerCacheInstance = InModuleScope $ProjectName {
                [DnsServerCache]::new()
            }

            # Override Get() method
            $mockDnsServerCacheInstance |
                Add-Member -Force -MemberType ScriptMethod -Name Get -Value {
                    return InModuleScope $ProjectName {
                        [DnsServerCache] @{
                            DnsServer                        = 'localhost'
                            IgnorePolicies                   = $true
                            LockingPercent                   = 100
                            MaxKBSize                        = 0
                            MaxNegativeTtl                   = '00:15:00'
                            MaxTtl                           = '1.00:00:00'
                            EnablePollutionProtection        = $true
                            StoreEmptyAuthenticationResponse = $true
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

                $mockDnsServerCacheInstance.DnsServer = 'localhost'
                $mockDnsServerCacheInstance.$PropertyName = $PropertyValue

                { $mockDnsServerCacheInstance.Set() } | Should -Not -Throw

                Assert-MockCalled -CommandName Set-DnsServerCache -ModuleName $ProjectName -Exactly -Times 1 -Scope It
            }
        }

        Context 'When parameter DnsServer is set to ''dns.company.local''' {
            It 'Should set the desired value for property ''<PropertyName>''' -TestCases $testCases {
                param
                (
                    $PropertyName,
                    $PropertyValue
                )

                $mockDnsServerCacheInstance.DnsServer = 'dns.company.local'
                $mockDnsServerCacheInstance.$PropertyName = $PropertyValue

                { $mockDnsServerCacheInstance.Set() } | Should -Not -Throw

                Assert-MockCalled -CommandName Set-DnsServerCache -ModuleName $ProjectName -Exactly -Times 1 -Scope It
            }
        }
    }
}
