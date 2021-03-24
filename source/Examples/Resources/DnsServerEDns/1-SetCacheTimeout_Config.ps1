<#PSScriptInfo

.VERSION 1.0.0

.GUID 95d58494-7f07-4893-9afd-df5afc2a0509

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
        This configuration will change the cache timeout for
        extension mechanisms for DNS (EDNS) on the DNS server.
#>

Configuration SetCacheTimeout_Config
{
    Import-DscResource -ModuleName 'xDnsServer'

    Node localhost
    {
        DnsServerEDns 'SetCacheTimeout'
        {
            DnsServer    = 'localhost'
            CacheTimeout = '00:15:00'
        }
    }
}
