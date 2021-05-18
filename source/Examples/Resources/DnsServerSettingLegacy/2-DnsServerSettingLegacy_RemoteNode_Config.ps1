<#PSScriptInfo

.VERSION 1.0.0

.GUID affae535-1236-474e-a5c7-ada598ebcf71

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

Configuration DnsServerSettingLegacy_RemoteNode_Config
{
    Import-DscResource -ModuleName 'DnsServerDsc'

    Node localhost
    {
        DnsServerSettingLegacy 'DnsServerLegacyProperties'
        {
            DisjointNets         = $false
            NoForwarderRecursion = $true
            LogLevel
        }
    }
}
