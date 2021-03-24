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
    Describe 'Helper function ConvertTo-HashtableFromObject' -Tag 'Private' {
        BeforeAll {
            $script:mockItemName = 'contoso.com'
        }

        BeforeEach {
            $script:dscResourceObject = [DnsRecordSrv]::new()
            $script:dscResourceObject.ZoneName = $script:mockItemName
            $script:dscResourceObject.Ensure = [Ensure]::Present
        }

        Context 'When instance of class is convert to hashtable' {
            It 'Should not Throw' {
                { $script:conversionResult = $script:dscResourceObject | ConvertTo-HashtableFromObject } | Should -Not -Throw
            }

            It 'Should be a Hashtable' {
                $script:conversionResult | Should -BeOfType [System.Collections.Hashtable]
            }

            It 'Should have the same count of properties' {
                $script:conversionResult.Keys.Count | Should -Be $script:dscResourceObject.PSObject.Properties.Name.Count
            }

            It 'Should be the same value of key' {
                $script:dscResourceObject.PSObject.Properties.Name | ForEach-Object {
                    $script:conversionResult.ContainsKey($_) | Should -BeTrue
                    $script:conversionResult.$_ | Should -Be $dscResourceObject.$_
                }
            }
        }
    }
}
