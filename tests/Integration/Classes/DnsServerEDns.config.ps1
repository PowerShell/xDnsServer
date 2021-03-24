$ConfigurationData = @{
    AllNodes = @(
        @{
            NodeName        = 'localhost'
            CertificateFile = $env:DscPublicCertificatePath
        }
    )
}

<#
    .SYNOPSIS
        Disables probes.
#>
configuration DnsServerEDns_DisableProbes_Config
{
    Import-DscResource -ModuleName 'xDnsServer'

    node $AllNodes.NodeName
    {
        DnsServerEDns 'Integration_Test'
        {
            DnsServer    = 'localhost'
            EnableProbes = $false
        }
    }
}

<#
    .SYNOPSIS
        Enabled probes.
#>
configuration DnsServerEDns_EnableProbes_Config
{
    Import-DscResource -ModuleName 'xDnsServer'

    node $AllNodes.NodeName
    {
        DnsServerEDns 'Integration_Test'
        {
            DnsServer    = 'localhost'
            EnableProbes = $true
        }
    }
}

<#
    .SYNOPSIS
        Disables reception.
#>
configuration DnsServerEDns_DisableReception_Config
{
    Import-DscResource -ModuleName 'xDnsServer'

    node $AllNodes.NodeName
    {
        DnsServerEDns 'Integration_Test'
        {
            DnsServer       = 'localhost'
            EnableReception = $false
        }
    }
}

<#
    .SYNOPSIS
        Enabled reception.
#>
configuration DnsServerEDns_EnableReception_Config
{
    Import-DscResource -ModuleName 'xDnsServer'

    node $AllNodes.NodeName
    {
        DnsServerEDns 'Integration_Test'
        {
            DnsServer       = 'localhost'
            EnableReception = $true
        }
    }
}

<#
    .SYNOPSIS
        Set cache timeout.
#>
configuration DnsServerEDns_SetCacheTimeout_Config
{
    Import-DscResource -ModuleName 'xDnsServer'

    node $AllNodes.NodeName
    {
        DnsServerEDns 'Integration_Test'
        {
            DnsServer    = 'localhost'
            CacheTimeout = '0.00:30:00'
        }
    }
}
