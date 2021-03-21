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

Import-Module $ProjectName

InModuleScope $ProjectName {
    Describe 'ConvertTo-TimeSpan' -Tag 'Private' {
        Context 'When converting a valid time' {
            It 'Should return the correct value' {
                $result = ConvertTo-TimeSpan -Value '234'
                $result | Should -BeOfType [System.TimeSpan]
                $result.Days | Should -Be '234'
            }

            Context 'When passing value in pipeline' {
                It 'Should return the correct value' {
                    $result = '234' | ConvertTo-TimeSpan
                    $result | Should -BeOfType [System.TimeSpan]
                    $result.Days | Should -Be '234'
                }

            }
        }

        Context 'When converting a invalid string' {
            It 'Should return $null' {
                $result = ConvertTo-TimeSpan -Value '234a'
                $result | Should -BeNullOrEmpty
            }
        }
    }
}
