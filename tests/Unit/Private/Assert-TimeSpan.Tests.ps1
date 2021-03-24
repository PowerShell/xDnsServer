$ProjectPath = "$PSScriptRoot\..\..\.." | Convert-Path
$ProjectName = (Get-ChildItem $ProjectPath\*\*.psd1 | Where-Object -FilterScript {
        ($_.Directory.Name -match 'source|src' -or $_.Directory.Name -eq $_.BaseName) -and
        $(try
            {
                Test-ModuleManifest $_.FullName -ErrorAction Stop
            }
            catch
            {
                $false
            }) }
).BaseName

Import-Module $ProjectName -Force

InModuleScope $ProjectName {
    Describe 'Assert-TimeSpan' -Tag 'Private' {
        Context 'When asserting a valid time' {
            Context 'When passing value with named parameter' {
                It 'Should not throw an exception' {
                    { Assert-TimeSpan -PropertyName 'MyProperty' -Value '1.00:00:00' } | Should -Not -Throw
                }
            }

            Context 'When passing value in pipeline' {
                It 'Should not throw an exception' {
                    { '1.00:00:00' | Assert-TimeSpan -PropertyName 'MyProperty' } | Should -Not -Throw
                }
            }
        }

        Context 'When asserting a invalid string' {
            It 'Should throw the correct error message' {
                $mockExpectedErrorMessage = $script:localizedData.PropertyHasWrongFormat -f 'MyProperty', 'a.00:00:00'

                { 'a.00:00:00' | Assert-TimeSpan -PropertyName 'MyProperty' } | Should -Throw $mockExpectedErrorMessage
            }
        }

        Context 'When time is above maximum allowed value' {
            It 'Should throw the correct error message' {
                $mockExpectedErrorMessage = $script:localizedData.TimeSpanExceedMaximumValue -f 'MyProperty', '1.00:00:00', '00:30:00'

                { '1.00:00:00' | Assert-TimeSpan -PropertyName 'MyProperty' -Maximum '0.00:30:00' } | Should -Throw $mockExpectedErrorMessage
            }
        }

        Context 'When time is below minimum allowed value' {
            It 'Should throw the correct error message' {
                $mockExpectedErrorMessage = $script:localizedData.TimeSpanBelowMinimumValue -f 'MyProperty', '1.00:00:00', '2.00:00:00'

                { '1.00:00:00' | Assert-TimeSpan -PropertyName 'MyProperty' -Minimum '2.00:00:00' } | Should -Throw $mockExpectedErrorMessage
            }
        }
    }
}
