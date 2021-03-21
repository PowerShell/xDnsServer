<#PSScriptInfo

.VERSION 1.0.0

.GUID 6b985cf2-8c93-47d7-9b90-31b28ec5147d

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
Updated author, copyright notice, and URLs.

.PRIVATEDATA 2016-Datacenter,2016-Datacenter-Server-Core

#>

#Requires -Module xDnsServer

<#
    .DESCRIPTION
        This configuration will disable scavenging on the DNS server.
#>

Configuration DisableScavenging_Config
{
    Import-DscResource -ModuleName 'xDnsServer'

    Node localhost
    {
        DnsServerScavenging 'EnableScavenging'
        {
            DnsServer = 'localhost'
            ScavengingState = $false
        }
    }
}
