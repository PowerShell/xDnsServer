$script:dscModuleName = 'xDnsServer'
$script:dscResourceFriendlyName = 'xDnsRecordSrv'
$script:dscResourceName = "MSFT_$($script:dscResourceFriendlyName)"

try
{
    Import-Module -Name DscResource.Test -Force -ErrorAction 'Stop'
}
catch [System.IO.FileNotFoundException]
{
    throw 'DscResource.Test module dependency not found. Please run ".\build.ps1 -Tasks build" first.'
}

$initializationParams = @{
    DSCModuleName = $script:dscModuleName
    DSCResourceName = $script:dscResourceName
    ResourceType = 'Mof'
    TestType = 'Integration'
}
$script:testEnvironment = Initialize-TestEnvironment @initializationParams

#region INITIALIZATION

Add-DnsServerPrimaryZone -Name 'srv.test' -ZoneFile 'srv.test.dns' -ErrorAction SilentlyContinue

#endregion

# Using try/finally to always cleanup.
try
{
    #region Integration Tests
    $configurationFile = Join-Path -Path $PSScriptRoot -ChildPath "$($script:dscResourceName).config.ps1"
    . $configurationFile

    Describe "$($script:dscResourceName)_Integration" {
        BeforeAll {
            $resourceId = "[$($script:dscResourceFriendlyName)]Integration_Test"
        }

        $configurationName = "$($script:dscResourceName)_CreateRecord_Config"

        Context ('When using configuration {0}' -f $configurationName) {
            It 'Should compile and apply the MOF without throwing' {
                {
                    $configurationParameters = @{
                        OutputPath        = $TestDrive
                        ConfigurationData = $ConfigurationData
                    }

                    & $configurationName @configurationParameters

                    $startDscConfigurationParameters = @{
                        Path         = $TestDrive
                        ComputerName = 'localhost'
                        Wait         = $true
                        Verbose      = $true
                        Force        = $true
                        ErrorAction  = 'Stop'
                    }

                    Start-DscConfiguration @startDscConfigurationParameters
                } | Should -Not -Throw
            }

            It 'Should be able to call Get-DscConfiguration without throwing' {
                {
                    $script:currentConfiguration = Get-DscConfiguration -Verbose -ErrorAction Stop
                } | Should -Not -Throw
            }

            It 'Should have set the resource and all the parameters should match' {
                $resourceCurrentState = $script:currentConfiguration | Where-Object -FilterScript {
                    $_.ConfigurationName -eq $configurationName -and $_.ResourceId -eq $resourceId
                }

                $shouldBeData = $ConfigurationData.NonNodeData.$configurationName

                # Key properties
                $resourceCurrentState.Zone | Should -Be $shouldBeData.Zone
                $resourceCurrentState.SymbolicName | Should -Be $shouldBeData.SymbolicName
                $resourceCurrentState.Protocol | Should -Be $shouldBeData.Protocol
                $resourceCurrentState.Port | Should -Be $shouldBeData.Port
                $resourceCurrentState.Target | Should -Be $shouldBeData.Target

                # Mandatory properties
                $resourceCurrentState.Priority | Should -Be $shouldBeData.Priority
                $resourceCurrentState.Weight | Should -Be $shouldBeData.Weight

                # Optional properties were not specified, so we just need to ensure the value exists
                $resourceCurrentState.TTL | Should -Not -Be $null

                # Defaulted properties
                $resourceCurrentState.DnsServer | Should -Be 'localhost'
                $resourceCurrentState.Ensure | Should -Be 'Present'
            }

            It 'Should return ''True'' when Test-DscConfiguration is run' {
                Test-DscConfiguration -Verbose | Should -Be 'True'
            }
        }

        Wait-ForIdleLcm -Clear

        $configurationName = "$($script:dscResourceName)_ModifyRecord_Config"

        Context ('When using configuration {0}' -f $configurationName) {
            It 'Should compile and apply the MOF without throwing' {
                {
                    $configurationParameters = @{
                        OutputPath        = $TestDrive
                        ConfigurationData = $ConfigurationData
                    }

                    & $configurationName @configurationParameters

                    $startDscConfigurationParameters = @{
                        Path         = $TestDrive
                        ComputerName = 'localhost'
                        Wait         = $true
                        Verbose      = $true
                        Force        = $true
                        ErrorAction  = 'Stop'
                    }

                    Start-DscConfiguration @startDscConfigurationParameters
                } | Should -Not -Throw
            }

            It 'Should be able to call Get-DscConfiguration without throwing' {
                {
                    $script:currentConfiguration = Get-DscConfiguration -Verbose -ErrorAction Stop
                } | Should -Not -Throw
            }

            It 'Should have set the resource and all the parameters should match' {
                $resourceCurrentState = $script:currentConfiguration | Where-Object -FilterScript {
                    $_.ConfigurationName -eq $configurationName -and $_.ResourceId -eq $resourceId
                }

                $shouldBeData = $ConfigurationData.NonNodeData.$configurationName

                # Key properties
                $resourceCurrentState.Zone | Should -Be $shouldBeData.Zone
                $resourceCurrentState.SymbolicName | Should -Be $shouldBeData.SymbolicName
                $resourceCurrentState.Protocol | Should -Be $shouldBeData.Protocol
                $resourceCurrentState.Port | Should -Be $shouldBeData.Port
                $resourceCurrentState.Target | Should -Be $shouldBeData.Target

                # Mandatory properties
                $resourceCurrentState.Priority | Should -Be $shouldBeData.Priority
                $resourceCurrentState.Weight | Should -Be $shouldBeData.Weight

                # Optional properties
                $resourceCurrentState.TTL | Should -Be $shouldBeData.TTL

                # Defaulted properties
                $resourceCurrentState.DnsServer | Should -Be $shouldBeData.DnsServer
                $resourceCurrentState.Ensure | Should -Be $shouldBeData.Ensure
            }

            It 'Should return ''True'' when Test-DscConfiguration is run' {
                Test-DscConfiguration -Verbose | Should -Be 'True'
            }
        }

        Wait-ForIdleLcm -Clear

        $configurationName = "$($script:dscResourceName)_DeleteRecord_Config"

        Context ('When using configuration {0}' -f $configurationName) {
            It 'Should compile and apply the MOF without throwing' {
                {
                    $configurationParameters = @{
                        OutputPath        = $TestDrive
                        ConfigurationData = $ConfigurationData
                    }

                    & $configurationName @configurationParameters

                    $startDscConfigurationParameters = @{
                        Path         = $TestDrive
                        ComputerName = 'localhost'
                        Wait         = $true
                        Verbose      = $true
                        Force        = $true
                        ErrorAction  = 'Stop'
                    }

                    Start-DscConfiguration @startDscConfigurationParameters
                } | Should -Not -Throw
            }

            It 'Should be able to call Get-DscConfiguration without throwing' {
                {
                    $script:currentConfiguration = Get-DscConfiguration -Verbose -ErrorAction Stop
                } | Should -Not -Throw
            }

            It 'Should have set the resource and all the parameters should match' {
                $resourceCurrentState = $script:currentConfiguration | Where-Object -FilterScript {
                    $_.ConfigurationName -eq $configurationName -and $_.ResourceId -eq $resourceId
                }

                $shouldBeData = $ConfigurationData.NonNodeData.$configurationName

                # Key properties
                $resourceCurrentState.Zone | Should -Be $shouldBeData.Zone
                $resourceCurrentState.SymbolicName | Should -Be $shouldBeData.SymbolicName
                $resourceCurrentState.Protocol | Should -Be $shouldBeData.Protocol
                $resourceCurrentState.Port | Should -Be $shouldBeData.Port
                $resourceCurrentState.Target | Should -Be $shouldBeData.Target

                # Mandatory properties
                $resourceCurrentState.Priority | Should -Be $shouldBeData.Priority
                $resourceCurrentState.Weight | Should -Be $shouldBeData.Weight

                # Optional properties
                $resourceCurrentState.TTL | Should -Be $shouldBeData.TTL

                # DnsServer is not specified in this test, so it defaults to 'localhost'
                $resourceCurrentState.DnsServer | Should -Be 'localhost'

                # Ensure will be Absent
                $resourceCurrentState.Ensure | Should -Be $shouldBeData.Ensure
            }

            It 'Should return ''True'' when Test-DscConfiguration is run' {
                Test-DscConfiguration -Verbose | Should -Be 'True'
            }
        }

        Wait-ForIdleLcm -Clear
    }
    #endregion
}
finally
{
    Restore-TestEnvironment -TestEnvironment $script:testEnvironment
}
