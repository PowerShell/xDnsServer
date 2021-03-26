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
    Describe 'Get-ClassName' -Tag 'Private' {
        BeforeAll {
            [System.UInt32] $mockObject = 3
        }

        Context 'When getting the class name' {
            Context 'When passing value with named parameter' {
                It 'Should return the correct value' {
                    $result = Get-ClassName -InputObject $mockObject

                    $result.GetType().FullName | Should -Be 'System.Object[]'

                    $result | Should -HaveCount 1
                    $result | Should -Contain 'System.UInt32'
                }
            }

            Context 'When passing value in pipeline' {
                It 'Should return the correct value' {
                    $result = $mockObject | Get-ClassName

                    $result.GetType().FullName | Should -Be 'System.Object[]'

                    $result | Should -HaveCount 1
                    $result | Should -Contain 'System.UInt32'
                }
            }
        }

        Context 'When getting the class name and all inherited class names (base classes)' {
            Context 'When passing value with named parameter' {
                It 'Should return the correct value' {
                    $result = Get-ClassName -InputObject $mockObject -Recursive

                    $result.GetType().FullName | Should -Be 'System.Object[]'

                    $result | Should -HaveCount 2
                    $result | Should -Contain 'System.UInt32'
                    $result | Should -Contain 'System.ValueType'

                    $result[0] | Should -Be 'System.UInt32'
                    $result[1] | Should -Be 'System.ValueType'
                }
            }

            Context 'When passing value in pipeline' {
                It 'Should return the correct value' {
                    $result = $mockObject | Get-ClassName -Recursive

                    $result.GetType().FullName | Should -Be 'System.Object[]'

                    $result | Should -HaveCount 2
                    $result | Should -Contain 'System.UInt32'
                    $result | Should -Contain 'System.ValueType'

                    $result[0] | Should -Be 'System.UInt32'
                    $result[1] | Should -Be 'System.ValueType'
                }
            }
        }
    }
}
