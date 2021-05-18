<#PSScriptInfo

.VERSION 1.0.1

.GUID a1a5300b-92c9-4443-8016-c305c6fbbfbb

.AUTHOR DSC Community

.COMPANYNAME DSC Community

.COPYRIGHT DSC Community contributors. All rights reserved.

.TAGS DSCConfiguration

.LICENSEURI https://github.com/dsccommunity/DnsServerDsc/blob/main/LICENSE

.PROJECTURI https://github.com/dsccommunity/DnsServerDsc

.ICONURI https://dsccommunity.org/images/DSC_Logo_300p.png

.EXTERNALMODULEDEPENDENCIES

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES
First version.

.PRIVATEDATA 2016-Datacenter,2016-Datacenter-Server-Core

#>

#Requires -Module DnsServerDsc


<#
    .DESCRIPTION
        This configuration will manage the DNS server legacy settings on the current
        node.
#>

Configuration DnsServerSettingLegacy_CurrentNode_Config
{
    Import-DscResource -ModuleName 'DnsServerDsc'

    Node localhost
    {
        DnsServerSettingLegacy 'DnsServerLegacyProperties'
        {
            DnsServer            = 'localhost'
            DisjointNets         = $false
            NoForwarderRecursion = $true
            LogLevel             = 50393905
        }
    }
}
