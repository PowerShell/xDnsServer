<#PSScriptInfo

.VERSION 1.0.1

.GUID 1d48864f-a258-4e2a-b67a-b5374c29520c

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
Updated author, copyright notice, and URLs.

.PRIVATEDATA 2016-Datacenter,2016-Datacenter-Server-Core

#>

#Requires -Module DnsServerDsc


<#
    .DESCRIPTION
        This configuration will manage the DNS server settings on the current
        node.
#>

Configuration DnsServerSetting_CurrentNode_Config
{
    Import-DscResource -ModuleName 'DnsServerDsc'

    Node localhost
    {
        DnsServerSetting 'DnsServerProperties'
        {
            DnsServer           = 'localhost'
            ListeningIPAddress    = '10.0.0.4'
            IsSlave            = $true
            RoundRobin         = $true
            LocalNetPriority   = $true
            BindSecondaries    = $false
            StrictFileParsing  = $false
            LogLevel           = 50393905
        }
    }
}
