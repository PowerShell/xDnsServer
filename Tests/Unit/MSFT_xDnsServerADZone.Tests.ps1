$Global:DSCModuleName      = 'xDnsServer'
$Global:DSCResourceName    = 'MSFT_xDnsServerADZone'

#region HEADER
[String] $moduleRoot = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $Script:MyInvocation.MyCommand.Path))
if ( (-not (Test-Path -Path (Join-Path -Path $moduleRoot -ChildPath 'DSCResource.Tests'))) -or `
     (-not (Test-Path -Path (Join-Path -Path $moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1'))) )
{
    & git @('clone','https://github.com/PowerShell/DscResource.Tests.git',(Join-Path -Path $moduleRoot -ChildPath '\DSCResource.Tests\'))
}
else
{
    & git @('-C',(Join-Path -Path $moduleRoot -ChildPath '\DSCResource.Tests\'),'pull')
}
Import-Module (Join-Path -Path $moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1') -Force
$TestEnvironment = Initialize-TestEnvironment `
    -DSCModuleName $Global:DSCModuleName `
    -DSCResourceName $Global:DSCResourceName `
    -TestType Unit 
#endregion

# Begin Testing
try
{
    #region Pester Tests

    InModuleScope $Global:DSCResourceName {
        #region Pester Test Initialization
        $testZoneName = 'example.com';
        $testDynamicUpdate = 'Secure';
        $testReplicationScope = 'Domain';
        $testComputerName = 'dnsserver.local';
        $testCredential = New-Object System.Management.Automation.PSCredential 'DummyUser', (ConvertTo-SecureString 'DummyPassword' -AsPlainText -Force);
        $testDirectoryPartitionName = "DomainDnsZones.$testZoneName";
        $testParams = @{ Name = $testZoneName; }

        $fakeDnsADZone = [PSCustomObject] @{
            DistinguishedName = $null;
            ZoneName = $testZoneName;
            ZoneType = 'Primary';
            DynamicUpdate = $testDynamicUpdate;
            ReplicationScope = $testReplicationScope;
            DirectoryPartitionName = $testDirectoryPartitionName;
            ZoneFile = $null;
        }

        $fakePresentTargetResource = @{
            Name = $testZoneName
            DynamicUpdate = $testDynamicUpdate
            ReplicationScope = $testReplicationScope;
            DirectoryPartitionName = $testDirectoryPartitionName;
            Ensure = 'Present'
        }

        $fakeAbsentTargetResource = @{ Ensure = 'Absent' }
        #endregion

        #region Function Get-TargetResource
        Describe "$($Global:DSCResourceName)\Get-TargetResource" {
            function Get-DnsServerZone { }

            Mock -CommandName 'Assert-Module' -MockWith { }

            It 'Returns a "System.Collections.Hashtable" object type with schema properties' {
                $targetResource = Get-TargetResource @testParams -ReplicationScope $testReplicationScope;
                $targetResource -is [System.Collections.Hashtable] | Should Be $true;

                $schemaFields = @('Name', 'DynamicUpdate', 'ReplicationScope', 'DirectoryPartitionName', 'Ensure');
                ($Null -eq ($targetResource.Keys.GetEnumerator() | Where-Object -FilterScript { $schemaFields -notcontains $_ })) | Should Be $true;
            }

            It 'Returns "Present" when DNS zone exists and "Ensure" = "Present"' {
                Mock -CommandName Get-DnsServerZone -MockWith { return $fakeDnsADZone; }
                $targetResource = Get-TargetResource @testParams -ReplicationScope $testReplicationScope;
                $targetResource.Ensure | Should Be 'Present';
            }

            It 'Returns "Absent" when DNS zone does not exists and "Ensure" = "Present"' {
                Mock -CommandName Get-DnsServerZone -MockWith { }
                $targetResource = Get-TargetResource @testParams -ReplicationScope $testReplicationScope;
                $targetResource.Ensure | Should Be 'Absent';
            }

            It 'Returns "Present" when DNS zone exists and "Ensure" = "Absent"' {
                Mock -CommandName Get-DnsServerZone -MockWith { return $fakeDnsADZone; }
                $targetResource = Get-TargetResource @testParams -ReplicationScope $testReplicationScope -Ensure Absent;
                $targetResource.Ensure | Should Be 'Present';
            }

            It 'Returns "Absent" when DNS zone does not exist and "Ensure" = "Absent"' {
                Mock -CommandName Get-DnsServerZone -MockWith { }
                $targetResource = Get-TargetResource @testParams -ReplicationScope $testReplicationScope -Ensure Absent;
                $targetResource.Ensure | Should Be 'Absent';
            }

            Context 'When a computername is not passed' {
                It 'Should not call New-CimSession' {
                    Mock -CommandName New-CimSession -MockWith { }
                    Get-TargetResource @testParams -ReplicationScope $testReplicationScope;
                    Assert-MockCalled -CommandName New-CimSession -Scope It -Times 0 -Exactly;
                }

                It 'Should not call Remove-CimSession' {
                    Mock -CommandName Remove-CimSession -MockWith { }
                    Get-TargetResource @testParams -ReplicationScope $testReplicationScope;
                    Assert-MockCalled -CommandName Remove-CimSession -Scope It -Times 0 -Exactly;
                }

                Context 'When credential is passed' {
                    It 'Should throw an exception indicating a computername must also be passed' {
                        $withCredentialsParameter = $testParams + @{
                            Credential = $testCredential
                        }
                        { Get-TargetResource @withCredentialsParameter -ReplicationScope $testReplicationScope } | Should -Throw 
                    }
                }
            }

            Context 'When a computername is passed' {
                It 'Should call New-CimSession' {
                    $withComputerNameParameter = $testParams + @{
                        ComputerName = $testComputerName
                    }
                    Mock -CommandName New-CimSession -MockWith { }
                    Get-TargetResource @withComputerNameParameter -ReplicationScope $testReplicationScope;
                    Assert-MockCalled -CommandName New-CimSession -ParameterFilter { $computername -eq $withComputerNameParameter.ComputerName } -Scope It -Times 1 -Exactly;
                }
                It 'Should call Remove-CimSession' {
                    $withComputerNameParameter = $testParams + @{
                        ComputerName = $testComputerName
                    }
                    Mock -CommandName New-CimSession -MockWith { New-MockObject -Type Microsoft.Management.Infrastructure.CimSession }
                    Mock -CommandName Remove-CimSession -MockWith { }
                    Get-TargetResource @withComputerNameParameter -ReplicationScope $testReplicationScope;
                    Assert-MockCalled -CommandName Remove-CimSession -Scope It -Times 1 -Exactly;
                }
                Context 'When credentials are passed' {
                    It 'Should throw an exception indicating a computername must also be passed' {
                        $withCredentialsAndComputerParameter = $testParams + @{
                            ComputerName = $testComputerName
                            Credential = $testCredential
                        }
                        Mock -CommandName New-CimSession -MockWith { }
                        Get-TargetResource @withCredentialsAndComputerParameter -ReplicationScope $testReplicationScope;
                        Assert-MockCalled -CommandName New-CimSession -ParameterFilter { $computername -eq $withCredentialsAndComputerParameter.ComputerName -and $credential -eq $withCredentialsAndComputerParameter.Credential } -Scope It -Times 1 -Exactly;
                    }
                }
            }
        }
        #endregion


        #region Function Test-TargetResource
        Describe "$($Global:DSCResourceName)\Test-TargetResource" {
            function Get-DnsServerZone { }
            
            It 'Returns a "System.Boolean" object type' {
                Mock -CommandName Get-TargetResource -MockWith { return $fakePresentTargetResource; }
                $targetResource =  Test-TargetResource @testParams -ReplicationScope $testReplicationScope;
                $targetResource -is [System.Boolean] | Should Be $true;
            }

            It 'Passes when DNS zone exists and "Ensure" = "Present"' {
                Mock -CommandName Get-TargetResource -MockWith { return $fakePresentTargetResource; }
                Test-TargetResource @testParams -Ensure Present -ReplicationScope $testReplicationScope | Should Be $true;
            }

            It 'Passes when DNS zone does not exist and "Ensure" = "Absent"' {
                Mock -CommandName Get-TargetResource -MockWith {  }
                Test-TargetResource @testParams -Ensure Absent -ReplicationScope $testReplicationScope | Should Be $true;
            }

            It 'Passes when DNS zone "DynamicUpdate" is correct' {
                Mock -CommandName Get-TargetResource -MockWith { return $fakePresentTargetResource; }
                Test-TargetResource @testParams -Ensure Present -ReplicationScope $testReplicationScope -DynamicUpdate $testDynamicUpdate | Should Be $true;
            }

            It 'Passes when DNS zone "ReplicationScope" is correct' {
                Mock -CommandName Get-TargetResource -MockWith { return $fakePresentTargetResource; }
                Test-TargetResource @testParams -Ensure Present -ReplicationScope $testReplicationScope | Should Be $true;
            }

            It 'Passes when DNS zone "DirectoryPartitionName" is correct' {
                Mock -CommandName Get-TargetResource -MockWith { return $fakePresentTargetResource; }
                Test-TargetResource @testParams -Ensure Present -ReplicationScope $testReplicationScope -DirectoryPartitionName $testDirectoryPartitionName | Should Be $true;
            }

            It 'Fails when DNS zone exists and "Ensure" = "Absent"' {
                Mock -CommandName Get-TargetResource -MockWith { return $fakePresentTargetResource; }
                Test-TargetResource @testParams -Ensure Absent -ReplicationScope $testReplicationScope | Should Be $false;
            }

            It 'Fails when DNS zone does not exist and "Ensure" = "Present"' {
                Mock -CommandName Get-TargetResource -MockWith { }
                Test-TargetResource @testParams -Ensure Present -ReplicationScope $testReplicationScope | Should Be $false;
            }

            It 'Fails when DNS zone "DynamicUpdate" is incorrect' {
                Mock -CommandName Get-TargetResource -MockWith { return $fakePresentTargetResource; }
                Test-TargetResource @testParams -Ensure Present -ReplicationScope $testReplicationScope -DynamicUpdate 'NonsecureAndSecure' | Should Be $false;
            }

            It 'Fails when DNS zone "ReplicationScope" is incorrect' {
                Mock -CommandName Get-TargetResource -MockWith { return $fakePresentTargetResource; }
                Test-TargetResource @testParams -Ensure Present -ReplicationScope 'Forest' | Should Be $false;
            }

            It 'Fails when DNS zone "DirectoryPartitionName" is incorrect' {
                Mock -CommandName Get-TargetResource -MockWith { return $fakePresentTargetResource; }
                Test-TargetResource @testParams -Ensure Present -ReplicationScope $testReplicationScope -DirectoryPartitionName 'IncorrectDirectoryPartitionName' | Should Be $false;
            }
        }
        #endregion


        #region Function Set-TargetResource
        Describe "$($Global:DSCResourceName)\Set-TargetResource" {
            function Get-DnsServerZone { }
            function Add-DnsServerPrimaryZone { param ( $Name ) }
            function Set-DnsServerPrimaryZone { [CmdletBinding()] param (
                $Name,
                $DynamicUpdate,
                $ReplicationScope,
                $DirectoryPartitionName,
                $CimSession ) }
            function Remove-DnsServerZone { }

            It 'Calls "Add-DnsServerPrimaryZone" when DNS zone does not exist and "Ensure" = "Present"' {
                Mock -CommandName Get-TargetResource -MockWith { return $fakeAbsentTargetResource }
                Mock -CommandName Add-DnsServerPrimaryZone -ParameterFilter { $Name -eq $testZoneName } -MockWith { }
                Set-TargetResource @testParams -Ensure Present -ReplicationScope $testReplicationScope -DynamicUpdate $testDynamicUpdate;
                Assert-MockCalled -CommandName Add-DnsServerPrimaryZone -ParameterFilter { $Name -eq $testZoneName } -Scope It;
            }

            It 'Calls "Remove-DnsServerZone" when DNS zone does exist and "Ensure" = "Absent"' {
                Mock -CommandName Get-TargetResource -MockWith { return $fakePresentTargetResource; }
                Mock -CommandName Remove-DnsServerZone -MockWith { }
                Set-TargetResource @testParams -Ensure Absent -ReplicationScope $testReplicationScope -DynamicUpdate $testDynamicUpdate;
                Assert-MockCalled -CommandName Remove-DnsServerZone -Scope It;
            }

            It 'Calls "Set-DnsServerPrimaryZone" when DNS zone "DynamicUpdate" is incorrect' {
                Mock -CommandName Get-TargetResource -MockWith { return $fakePresentTargetResource; }
                Mock -CommandName Set-DnsServerPrimaryZone -ParameterFilter { $DynamicUpdate -eq 'NonsecureAndSecure' } -MockWith { }
                Set-TargetResource @testParams -Ensure Present -ReplicationScope $testReplicationScope -DynamicUpdate 'NonsecureAndSecure';
                Assert-MockCalled -CommandName Set-DnsServerPrimaryZone -ParameterFilter { $DynamicUpdate -eq 'NonsecureAndSecure' } -Scope It;
            }

            It 'Calls "Set-DnsServerPrimaryZone" when DNS zone "ReplicationScope" is incorrect' {
                Mock -CommandName Get-TargetResource -MockWith { return $fakePresentTargetResource; }
                Mock -CommandName Set-DnsServerPrimaryZone -ParameterFilter { $ReplicationScope -eq 'Forest' } -MockWith { }
                Set-TargetResource @testParams -Ensure Present -ReplicationScope 'Forest';
                Assert-MockCalled -CommandName Set-DnsServerPrimaryZone -ParameterFilter { $ReplicationScope -eq 'Forest' } -Scope It;
            }

            It 'Calls "Set-DnsServerPrimaryZone" when DNS zone "DirectoryPartitionName" is incorrect' {
                Mock -CommandName Get-TargetResource -MockWith { return $fakePresentTargetResource; }
                Mock -CommandName Set-DnsServerPrimaryZone -ParameterFilter { $DirectoryPartitionName -eq 'IncorrectDirectoryPartitionName' } -MockWith { }
                Set-TargetResource @testParams -Ensure Present -ReplicationScope $testReplicationScope -DirectoryPartitionName 'IncorrectDirectoryPartitionName';
                Assert-MockCalled -CommandName Set-DnsServerPrimaryZone -ParameterFilter { $DirectoryPartitionName -eq 'IncorrectDirectoryPartitionName' } -Scope It;
            }

            Context 'When a computername is not passed' {
                It 'Should not call New-CimSession' {
                    Mock -CommandName Get-TargetResource -MockWith { return $fakePresentTargetResource; }
                    Mock -CommandName New-CimSession -MockWith { }
                    Set-TargetResource @testParams -ReplicationScope $testReplicationScope;
                    Assert-MockCalled -CommandName New-CimSession -Scope It -Times 0 -Exactly;
                }

                It 'Should not call Remove-CimSession' {
                    Mock -CommandName Get-TargetResource -MockWith { return $fakePresentTargetResource; }
                    Mock -CommandName Remove-CimSession -MockWith { }
                    Set-TargetResource @testParams -ReplicationScope $testReplicationScope;
                    Assert-MockCalled -CommandName Remove-CimSession -Scope It -Times 0 -Exactly;
                }
            }

            Context 'When a computername is passed' {
                It 'Should call New-CimSession' {
                    $withComputerNameParameter = $testParams + @{
                        ComputerName = $testComputerName
                    }
                    Mock -CommandName Get-TargetResource -MockWith { return $fakePresentTargetResource; }
                    Mock -CommandName New-CimSession -MockWith { }
                    Set-TargetResource @withComputerNameParameter -ReplicationScope $testReplicationScope;
                    Assert-MockCalled -CommandName New-CimSession -ParameterFilter { $computername -eq $withComputerNameParameter.ComputerName } -Scope It -Times 1 -Exactly;
                }
                It 'Should call Remove-CimSession' {
                    $withComputerNameParameter = $testParams + @{
                        ComputerName = $testComputerName
                    }
                    Mock -CommandName Get-TargetResource -MockWith { return $fakePresentTargetResource; }
                    Mock -CommandName New-CimSession -MockWith { New-MockObject -Type Microsoft.Management.Infrastructure.CimSession }
                    Mock -CommandName Remove-CimSession -MockWith { }
                    Set-TargetResource @withComputerNameParameter -ReplicationScope $testReplicationScope;
                    Assert-MockCalled -CommandName Remove-CimSession -Scope It -Times 1 -Exactly;
                }
                Context 'When credentials are passed' {
                    It 'Should throw an exception indicating a computername must also be passed' {
                        $withCredentialsAndComputerParameter = $testParams + @{
                            ComputerName = $testComputerName
                            Credential = $testCredential
                        }
                        Mock -CommandName Get-TargetResource -MockWith { return $fakePresentTargetResource; }
                        Mock -CommandName New-CimSession -MockWith { }
                        Set-TargetResource @withCredentialsAndComputerParameter -ReplicationScope $testReplicationScope;
                        Assert-MockCalled -CommandName New-CimSession -ParameterFilter { $computername -eq $withCredentialsAndComputerParameter.ComputerName -and $credential -eq $withCredentialsAndComputerParameter.Credential } -Scope It -Times 1 -Exactly;
                    }
                }
            }
        }
        #endregion
    } #end InModuleScope
}
finally
{
    #region FOOTER
    Restore-TestEnvironment -TestEnvironment $TestEnvironment
    #endregion
}
