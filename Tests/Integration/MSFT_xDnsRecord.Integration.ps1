
$script:DSCModuleName   = 'xDnsServer'
$script:DSCResourceName = 'MSFT_xDnsRecord'

#region HEADER
# Integration Test Template Version: 1.1.1
$script:moduleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
if ( (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests'))) -or `
(-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1'))) )
{
    & git @('clone','https://github.com/PowerShell/DscResource.Tests.git',(Join-Path -Path $script:moduleRoot -ChildPath '\DSCResource.Tests\'))
}

Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath (Join-Path -Path 'DSCResource.Tests' -ChildPath 'TestHelper.psm1')) -Force
$testEnvironment = Initialize-TestEnvironment `
-DSCModuleName $script:DSCModuleName `
-DSCResourceName $script:DSCResourceName `
-TestType Integration

#endregion

try
{
    #region Integration Tests
    $configFile = Join-Path -Path $PSScriptRoot -ChildPath "$($script:DSCResourceName).config.ps1"
    . $configFile

    Describe "$($script:DSCResourceName)_Integration" {
        #region DEFAULT TESTS
        It 'Should compile and apply the MOF without throwing' {
            {
                & "$($script:DSCResourceName)_Config" -OutputPath $testEnvironment.WorkingFolder
                Start-DscConfiguration -Path $testEnvironment.WorkingFolder `
                -ComputerName localhost -Wait -Verbose -Force
            } | Should not throw
        }

        It 'Should be able to call Get-DscConfiguration without throwing' {
            { Get-DscConfiguration -Verbose -ErrorAction Stop } | Should Not throw
        }
        #endregion

        It 'Should have set the resource and Test-DscConfiguration return $true' {
            Test-DscConfiguration | Should be $true
        }
    }
    #endregion

}
finally
{
    #region FOOTER

    Restore-TestEnvironment -TestEnvironment $testEnvironment

    #endregion

}
