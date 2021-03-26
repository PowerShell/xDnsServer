<#PSScriptInfo

.VERSION 1.0.0

.GUID 4c4f3794-41e8-4035-ba5c-a478675738e3

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
        This configuration will manage the DNS server settings on the current
        node.
#>

Configuration xDnsServerSetting_RemoteNode_Config
{
    Import-DscResource -ModuleName 'xDnsServer'

    Node localhost
    {
        xDnsServerSetting 'DnsServerProperties'
        {
            DnsServer           = 'dns1.company.local'
            ListenAddresses    = '10.0.0.4'
            IsSlave            = $true
            RoundRobin         = $true
            LocalNetPriority   = $true
            SecureResponses    = $true
            NoRecursion        = $false
            BindSecondaries    = $false
            StrictFileParsing  = $false
            LogLevel           = 50393905
        }
    }
}
