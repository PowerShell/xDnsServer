<#PSScriptInfo

.VERSION 1.0.0

.GUID 81765a8e-1b23-4199-9a39-b254807ad129

.AUTHOR DSC Community

.COMPANYNAME DSC Community

.COPYRIGHT DSC Community contributors. All rights reserved.

.TAGS DSCConfiguration

.LICENSEURI https://github.com/dsccommunity/xDnsServer/blob/main/LICENSE

.PROJECTURI https://github.com/dsccommunity/xDnsServer

.ICONURI https://dsccommunity.org/images/DSC_Logo_300p.png

.EXTERNALMODULEDEPENDENCIES

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES
First version.

.PRIVATEDATA 2016-Datacenter,2016-Datacenter-Server-Core

#>

#Requires -Module xDnsServer

<#
    .DESCRIPTION
        This configuration will allow to accepts queries for the extension mechanisms
        for DNS (EDNS) on the DNS server.
#>

Configuration EnableReception_Config.ps1
{
    Import-DscResource -ModuleName 'xDnsServer'

    Node localhost
    {
        DnsServerEDns 'EnableReception'
        {
            DnsServer       = 'localhost'
            EnableReception = $true
        }
    }
}
