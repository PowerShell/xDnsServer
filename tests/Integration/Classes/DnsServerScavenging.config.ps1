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
        Enables scavenging.
#>
configuration DnsServerScavenging_EnableScavenging_Config
{
    Import-DscResource -ModuleName 'xDnsServer'

    node $AllNodes.NodeName
    {
        DnsServerScavenging 'Integration_Test'
        {
            DnsServer       = 'localhost'
            ScavengingState = $true
        }
    }
}

<#
    .SYNOPSIS
        Sets all intervals.
#>
configuration DnsServerScavenging_SetAllIntervals_Config
{
    Import-DscResource -ModuleName 'xDnsServer'

    node $AllNodes.NodeName
    {
        DnsServerScavenging 'Integration_Test'
        {
            DnsServer          = 'localhost'
            ScavengingInterval = '30.00:00:00'
            RefreshInterval    = '30.00:00:00'
            NoRefreshInterval  = '30.00:00:00'
        }
    }
}

<#
    .SYNOPSIS
        Sets one interval.
#>
configuration DnsServerScavenging_SetOneInterval_Config
{
    Import-DscResource -ModuleName 'xDnsServer'

    node $AllNodes.NodeName
    {
        DnsServerScavenging 'Integration_Test'
        {
            DnsServer          = 'localhost'
            ScavengingInterval = '6.23:00:00'
        }
    }
}

<#
    .SYNOPSIS
        Disables scavenging.
#>
configuration DnsServerScavenging_DisableScavenging_Config
{
    Import-DscResource -ModuleName 'xDnsServer'

    node $AllNodes.NodeName
    {
        DnsServerScavenging 'Integration_Test'
        {
            DnsServer       = 'localhost'
            ScavengingState = $false
        }
    }
}
