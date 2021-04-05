$script:dscModuleName = 'DnsServerDsc'
$script:dscResourceName = 'DSC_DnsServerPrimaryZone'

function Invoke-TestSetup
{
    try
    {
        Import-Module -Name DscResource.Test -Force -ErrorAction 'Stop'
    }
    catch [System.IO.FileNotFoundException]
    {
        throw 'DscResource.Test module dependency not found. Please run ".\build.ps1 -Tasks build" first.'
    }

    $script:testEnvironment = Initialize-TestEnvironment `
        -DSCModuleName $script:dscModuleName `
        -DSCResourceName $script:dscResourceName `
        -ResourceType 'Mof' `
        -TestType 'Unit'

    Import-Module (Join-Path -Path $PSScriptRoot -ChildPath 'Stubs\DnsServer.psm1') -Force
}

function Invoke-TestCleanup
{
    Restore-TestEnvironment -TestEnvironment $script:testEnvironment
}

Invoke-TestSetup

try
{
    InModuleScope $script:dscResourceName {
        #region Pester Test Initialization
        $testZoneName = 'example.com'
        $testZoneFile = 'example.com.dns'
        $testDynamicUpdate = 'None'
        $testParams = @{
            Name    = $testZoneName
            Verbose = $true
        }

        $fakeDnsFileZone = [PSCustomObject] @{
            DistinguishedName      = $null
            ZoneName               = $testZoneName
            ZoneType               = 'Primary'
            DynamicUpdate          = $testDynamicUpdate
            ReplicationScope       = 'None'
            DirectoryPartitionName = $null
            ZoneFile               = $testZoneFile
        }
        #endregion

        #region Function Get-TargetResource
        Describe 'DSC_DnsServerPrimaryZone\Get-TargetResource' {
            Mock -CommandName 'Assert-Module'

            It 'Returns a "System.Collections.Hashtable" object type' {
                Mock -CommandName Get-DnsServerZone -MockWith { return $fakeDnsFileZone }
                $targetResource = Get-TargetResource @testParams
                $targetResource -is [System.Collections.Hashtable] | Should Be $true
            }

            It 'Returns "Present" when DNS zone exists and "Ensure" = "Present"' {
                Mock -CommandName Get-DnsServerZone -MockWith { return $fakeDnsFileZone }
                $targetResource = Get-TargetResource @testParams -ZoneFile 'example.com.dns'
                $targetResource.Ensure | Should Be 'Present'
            }

            It 'Returns "Absent" when DNS zone does not exists and "Ensure" = "Present"' {
                Mock -CommandName Get-DnsServerZone -MockWith { }
                $targetResource = Get-TargetResource @testParams -ZoneFile 'example.com.dns'
                $targetResource.Ensure | Should Be 'Absent'
            }

            It 'Returns "Present" when DNS zone exists and "Ensure" = "Absent"' {
                Mock -CommandName Get-DnsServerZone -MockWith { return $fakeDnsFileZone }
                $targetResource = Get-TargetResource @testParams -ZoneFile 'example.com.dns' -Ensure Absent
                $targetResource.Ensure | Should Be 'Present'
            }

            It 'Returns "Absent" when DNS zone does not exist and "Ensure" = "Absent"' {
                Mock -CommandName Get-DnsServerZone -MockWith { }
                $targetResource = Get-TargetResource @testParams -ZoneFile 'example.com.dns' -Ensure Absent
                $targetResource.Ensure | Should Be 'Absent'
            }
        }
        #endregion


        #region Function Test-TargetResource
        Describe 'DSC_DnsServerPrimaryZone\Test-TargetResource' {
            Mock -CommandName 'Assert-Module'

            It 'Returns a "System.Boolean" object type' {
                Mock -CommandName Get-DnsServerZone -MockWith { return $fakeDnsFileZone }
                $targetResource = Test-TargetResource @testParams
                $targetResource -is [System.Boolean] | Should Be $true
            }

            It 'Passes when DNS zone exists and "Ensure" = "Present"' {
                Mock -CommandName Get-DnsServerZone -MockWith { return $fakeDnsFileZone }
                Test-TargetResource @testParams -Ensure Present | Should Be $true
            }

            It 'Passes when DNS zone does not exist and "Ensure" = "Absent"' {
                Mock -CommandName Get-DnsServerZone -MockWith { }
                Test-TargetResource @testParams -Ensure Absent | Should Be $true
            }

            It 'Passes when DNS zone "DynamicUpdate" is correct' {
                Mock -CommandName Get-DnsServerZone -MockWith { return $fakeDnsFileZone }
                Test-TargetResource @testParams -Ensure Present -DynamicUpdate $testDynamicUpdate | Should Be $true
            }

            It 'Fails when DNS zone exists and "Ensure" = "Absent"' {
                Mock -CommandName Get-DnsServerZone -MockWith { return $fakeDnsFileZone }
                Test-TargetResource @testParams -Ensure Absent | Should Be $false
            }

            It 'Fails when DNS zone does not exist and "Ensure" = "Present"' {
                Mock -CommandName Get-DnsServerZone -MockWith { }
                Test-TargetResource @testParams -Ensure Present | Should Be $false
            }

            It 'Fails when DNS zone "DynamicUpdate" is incorrect' {
                Mock -CommandName Get-DnsServerZone -MockWith { return $fakeDnsFileZone }
                Test-TargetResource @testParams -Ensure Present -DynamicUpdate 'NonSecureAndSecure' -ZoneFile $testZoneFile | Should Be $false
            }

            It 'Fails when DNS zone "ZoneFile" is incorrect' {
                Mock -CommandName Get-DnsServerZone -MockWith { return $fakeDnsFileZone }
                Test-TargetResource @testParams -Ensure Present -DynamicUpdate $testDynamicUpdate -ZoneFile 'nonexistent.com.dns' | Should Be $false
            }
        }
        #endregion


        #region Function Set-TargetResource
        Describe 'DSC_DnsServerPrimaryZone\Set-TargetResource' {
            Mock -CommandName 'Assert-Module'

            It 'Calls "Add-DnsServerPrimaryZone" when DNS zone does not exist and "Ensure" = "Present"' {
                Mock -CommandName Get-DnsServerZone -MockWith { }
                Mock -CommandName Add-DnsServerPrimaryZone -ParameterFilter { $Name -eq $testZoneName } -MockWith { }
                Set-TargetResource @testParams -Ensure Present -DynamicUpdate $testDynamicUpdate -ZoneFile $testZoneFile
                Assert-MockCalled -CommandName Add-DnsServerPrimaryZone -ParameterFilter { $Name -eq $testZoneName } -Scope It
            }

            It 'Calls "Remove-DnsServerZone" when DNS zone does exist and "Ensure" = "Absent"' {
                Mock -CommandName Get-DnsServerZone -MockWith { return $fakeDnsFileZone }
                Mock -CommandName Remove-DnsServerZone -MockWith { }
                Set-TargetResource @testParams -Ensure Absent -DynamicUpdate $testDynamicUpdate -ZoneFile $testZoneFile
                Assert-MockCalled -CommandName Remove-DnsServerZone -Scope It
            }

            It 'Calls "Set-DnsServerPrimaryZone" when DNS zone "DynamicUpdate" is incorrect' {
                Mock -CommandName Get-DnsServerZone -MockWith { return $fakeDnsFileZone }
                Mock -CommandName Set-DnsServerPrimaryZone -ParameterFilter { $DynamicUpdate -eq 'NonSecureAndSecure' } -MockWith { }
                Set-TargetResource @testParams -Ensure Present -DynamicUpdate 'NonSecureAndSecure' -ZoneFile $testZoneFile
                Assert-MockCalled -CommandName Set-DnsServerPrimaryZone -ParameterFilter { $DynamicUpdate -eq 'NonSecureAndSecure' } -Scope It
            }

            It 'Calls "Set-DnsServerPrimaryZone" when DNS zone "ZoneFile" is incorrect' {
                Mock -CommandName Get-DnsServerZone -MockWith { return $fakeDnsFileZone }
                Mock -CommandName Set-DnsServerPrimaryZone -ParameterFilter { $ZoneFile -eq 'nonexistent.com.dns' } -MockWith { }
                Set-TargetResource @testParams -Ensure Present -DynamicUpdate $testDynamicUpdate -ZoneFile 'nonexistent.com.dns'
                Assert-MockCalled -CommandName Set-DnsServerPrimaryZone -ParameterFilter { $ZoneFile -eq 'nonexistent.com.dns' } -Scope It
            }
        }
        #endregion
    } #end InModuleScope
}
finally
{
    Invoke-TestCleanup
}
