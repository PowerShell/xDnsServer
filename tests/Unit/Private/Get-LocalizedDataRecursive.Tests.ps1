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
    Describe 'Get-LocalizedDataRecursive' -Tag 'Private' {
        BeforeAll {
            $getLocalizedData_ParameterFilter_Class = {
                $FileName -eq 'MyClassResource.strings.psd1'
            }

            $getLocalizedData_ParameterFilter_Base = {
                $FileName -eq 'MyBaseClass.strings.psd1'
            }

            Mock -CommandName Get-LocalizedData -MockWith {
                return @{
                    ClassStringKey = 'My class string'
                }
            } -ParameterFilter $getLocalizedData_ParameterFilter_Class

            Mock -CommandName Get-LocalizedData -MockWith {
                return @{
                    BaseStringKey = 'My base string'
                }
            } -ParameterFilter $getLocalizedData_ParameterFilter_Base
        }

        Context 'When getting localization string for class name' {
            Context 'When passing value with named parameter' {
                It 'Should return the correct localization strings' {
                    $result = Get-LocalizedDataRecursive -ClassName 'MyClassResource'

                    $result.Keys | Should -HaveCount 1
                    $result.Keys | Should -Contain 'ClassStringKey'

                    Assert-MockCalled -CommandName Get-LocalizedData -ParameterFilter $getLocalizedData_ParameterFilter_Class -Exactly -Times 1 -Scope It
                }
            }

            Context 'When passing value in pipeline' {
                It 'Should return the correct localization strings' {
                    $result = 'MyClassResource' | Get-LocalizedDataRecursive

                    $result.Keys | Should -HaveCount 1
                    $result.Keys | Should -Contain 'ClassStringKey'

                    Assert-MockCalled -CommandName Get-LocalizedData -ParameterFilter $getLocalizedData_ParameterFilter_Class -Exactly -Times 1 -Scope It
                }
            }
        }

        Context 'When getting localization string for class and base name' {
            Context 'When passing value with named parameter' {
                It 'Should return the correct localization strings' {
                    $result = Get-LocalizedDataRecursive -ClassName @('MyClassResource','MyBaseClass')

                    $result.Keys | Should -HaveCount 2
                    $result.Keys | Should -Contain 'ClassStringKey'
                    $result.Keys | Should -Contain 'BaseStringKey'

                    Assert-MockCalled -CommandName Get-LocalizedData -ParameterFilter $getLocalizedData_ParameterFilter_Class -Exactly -Times 1 -Scope It
                }
            }

            Context 'When passing value in pipeline' {
                It 'Should return the correct localization strings' {
                    $result = @('MyClassResource','MyBaseClass') | Get-LocalizedDataRecursive

                    $result.Keys | Should -HaveCount 2
                    $result.Keys | Should -Contain 'ClassStringKey'
                    $result.Keys | Should -Contain 'BaseStringKey'

                    Assert-MockCalled -CommandName Get-LocalizedData -ParameterFilter $getLocalizedData_ParameterFilter_Class -Exactly -Times 1 -Scope It
                }
            }
        }

        Context 'When getting localization string for class and base file name' {
            Context 'When passing value with named parameter' {
                It 'Should return the correct localization strings' {
                    $result = Get-LocalizedDataRecursive -ClassName @(
                        'MyClassResource.strings.psd1'
                        'MyBaseClass.strings.psd1'
                    )

                    $result.Keys | Should -HaveCount 2
                    $result.Keys | Should -Contain 'ClassStringKey'
                    $result.Keys | Should -Contain 'BaseStringKey'

                    Assert-MockCalled -CommandName Get-LocalizedData -ParameterFilter $getLocalizedData_ParameterFilter_Class -Exactly -Times 1 -Scope It
                }
            }

            Context 'When passing value in pipeline' {
                It 'Should return the correct localization strings' {
                    $result = @(
                        'MyClassResource.strings.psd1'
                        'MyBaseClass.strings.psd1'
                    ) | Get-LocalizedDataRecursive

                    $result.Keys | Should -HaveCount 2
                    $result.Keys | Should -Contain 'ClassStringKey'
                    $result.Keys | Should -Contain 'BaseStringKey'

                    Assert-MockCalled -CommandName Get-LocalizedData -ParameterFilter $getLocalizedData_ParameterFilter_Class -Exactly -Times 1 -Scope It
                }
            }
        }
    }
}
