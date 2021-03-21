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

Describe 'DnsServerScavenging\Get-TargetResource' -Tag 'Get' {
    BeforeAll {
        # Mocks for all context blocks. Avoid if possible.
    }

    # Context block cannot always be used.
    Context 'When the system is in the desired state' {
        BeforeAll {
            $mockDnsServerScavengingInstance = InModuleScope $ProjectName {
                [DnsServerScavenging]::new()
            }

            $mockDnsServerScavengingInstance.DnsServer = 'localhost'

            Mock -CommandName Get-DnsServerScavenging -ModuleName $ProjectName -MockWith {
                return New-CimInstance -ClassName 'DnsServerScavenging' -Namespace 'root/Microsoft/Windows/DNS' -ClientOnly -Property @{
                    ScavengingState = $true
                    ScavengingInterval = '30.00:00:00'
                    RefreshInterval = '30.00:00:00'
                    NoRefreshInterval = '30.00:00:00'
                    LastScavengeTime = '2021-01-01 00:00:00'
                }
            }
        }

        It 'Should have correct instantiated the resource class' {
            $mockDnsServerScavengingInstance | Should -Not -BeNullOrEmpty
            $mockDnsServerScavengingInstance.GetType().Name | Should -Be 'DnsServerScavenging'
        }

        It 'Should return the correct values for the properties' {
            $getResult = $mockDnsServerScavengingInstance.Get()

            $getResult.DnsServer | Should -Be 'localhost'
            $getResult.ScavengingState |Should -BeTrue

            Assert-MockCalled -CommandName Get-DnsServerScavenging -ModuleName $ProjectName -Exactly -Times 1 -Scope It
        }
    }

    Context 'When the system is the desired state' {
        BeforeAll {
            # Mocks when the system is in desired state
        }

        It 'Should...' {
            # Test when the system is in the desired state
        }
    }
}
