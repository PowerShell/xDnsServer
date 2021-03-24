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
configuration DnsServerScavenging_DisableProbes_Config
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
configuration DnsServerScavenging_EnableProbes_Config
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
configuration DnsServerScavenging_DisableReception_Config
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
configuration DnsServerScavenging_EnableReception_Config
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
configuration DnsServerScavenging_SetCacheTimeout_Config
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
