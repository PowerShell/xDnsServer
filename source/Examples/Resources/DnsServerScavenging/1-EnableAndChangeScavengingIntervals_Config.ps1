<#PSScriptInfo

.VERSION 1.0.0

.GUID 74a3fe1e-4094-4c78-b815-154c1907e54d

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
        This configuration will enable scavenging and change the scavenging intervals
        on the DNS server.
#>

Configuration EnableAndChangeScavengingIntervals_Config
{
    Import-DscResource -ModuleName 'xDnsServer'

    Node localhost
    {
        DnsServerScavenging 'EnableScavengingAndChangeIntervals'
        {
            DnsServer          = 'localhost'
            ScavengingState    = $true
            ScavengingInterval = '7.00:00:00'
            RefreshInterval    = '7.00:00:00'
            NoRefreshInterval  = '7.00:00:00'
        }
    }
}
