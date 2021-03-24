<#PSScriptInfo

.VERSION 1.0.0

.GUID a6427353-df6b-407f-b35c-1aa98822f286

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
        This configuration will enable probes for the extension mechanisms for DNS
        (EDNS) on the DNS server.
#>

Configuration EnableProbes_Config
{
    Import-DscResource -ModuleName 'xDnsServer'

    Node localhost
    {
        DnsServerEDns 'EnableProbes'
        {
            DnsServer    = 'localhost'
            EnableProbes = '7.00:00:00'
        }
    }
}
