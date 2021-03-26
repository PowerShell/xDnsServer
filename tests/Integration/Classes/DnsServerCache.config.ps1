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
        Test the property IgnorePolicies setting to $false.
#>
configuration DnsServerCache_UsePolicies_Config
{
    Import-DscResource -ModuleName 'xDnsServer'

    node $AllNodes.NodeName
    {
        DnsServerCache 'Integration_Test'
        {
            DnsServer      = 'localhost'
            IgnorePolicies = $false
        }
    }
}

<#
    .SYNOPSIS
        Test the property IgnorePolicies setting to $true.
#>
configuration DnsServerCache_IgnorePolicies_Config
{
    Import-DscResource -ModuleName 'xDnsServer'

    node $AllNodes.NodeName
    {
        DnsServerCache 'Integration_Test'
        {
            DnsServer      = 'localhost'
            IgnorePolicies = $true
        }
    }
}

<#
    .SYNOPSIS
        Test the property LockingPercent setting to 80 percent.
#>
configuration DnsServerCache_LockingPercent80_Config
{
    Import-DscResource -ModuleName 'xDnsServer'

    node $AllNodes.NodeName
    {
        DnsServerCache 'Integration_Test'
        {
            DnsServer      = 'localhost'
            LockingPercent = 80
        }
    }
}

<#
    .SYNOPSIS
        Test the property LockingPercent setting to 100 percent.
#>
configuration DnsServerCache_LockingPercent100_Config
{
    Import-DscResource -ModuleName 'xDnsServer'

    node $AllNodes.NodeName
    {
        DnsServerCache 'Integration_Test'
        {
            DnsServer      = 'localhost'
            LockingPercent = 100
        }
    }
}

<#
    .SYNOPSIS
        Test the property MaxKBSize setting to 1000 KB.
#>
configuration DnsServerCache_MaxKBSize1000_Config
{
    Import-DscResource -ModuleName 'xDnsServer'

    node $AllNodes.NodeName
    {
        DnsServerCache 'Integration_Test'
        {
            DnsServer = 'localhost'
            MaxKBSize = 1000
        }
    }
}

<#
    .SYNOPSIS
        Test the property MaxKBSize setting to 0 KB (Unlimited).
#>
configuration DnsServerCache_MaxKBSize0_Config
{
    Import-DscResource -ModuleName 'xDnsServer'

    node $AllNodes.NodeName
    {
        DnsServerCache 'Integration_Test'
        {
            DnsServer = 'localhost'
            MaxKBSize = 0
        }
    }
}

<#
    .SYNOPSIS
        Test the property MaxNegativeTtl setting to 1 hour.
#>
configuration DnsServerCache_MaxNegativeTtl1Hour_Config
{
    Import-DscResource -ModuleName 'xDnsServer'

    node $AllNodes.NodeName
    {
        DnsServerCache 'Integration_Test'
        {
            DnsServer      = 'localhost'
            MaxNegativeTtl = '01:00:00'
        }
    }
}

<#
    .SYNOPSIS
        Test the property MaxNegativeTtl setting to 15 minutes.
#>
configuration DnsServerCache_MaxNegativeTtl15minutes_Config
{
    Import-DscResource -ModuleName 'xDnsServer'

    node $AllNodes.NodeName
    {
        DnsServerCache 'Integration_Test'
        {
            DnsServer      = 'localhost'
            MaxNegativeTtl = '00:15:00'
        }
    }
}

<#
    .SYNOPSIS
        Test the property MaxTtl setting to 3 days.
#>
configuration DnsServerCache_MaxTtl3Days_Config
{
    Import-DscResource -ModuleName 'xDnsServer'

    node $AllNodes.NodeName
    {
        DnsServerCache 'Integration_Test'
        {
            DnsServer = 'localhost'
            MaxTtl    = '3.00:00:00'
        }
    }
}

<#
    .SYNOPSIS
        Test the property MaxTtl setting to 1 days.
#>
configuration DnsServerCache_MaxTtl1Days_Config
{
    Import-DscResource -ModuleName 'xDnsServer'

    node $AllNodes.NodeName
    {
        DnsServerCache 'Integration_Test'
        {
            DnsServer = 'localhost'
            MaxTtl    = '1.00:00:00'
        }
    }
}

<#
    .SYNOPSIS
        Test the property EnablePollutionProtection setting to $false.
#>
configuration DnsServerCache_DisablePollutionProtection_Config
{
    Import-DscResource -ModuleName 'xDnsServer'

    node $AllNodes.NodeName
    {
        DnsServerCache 'Integration_Test'
        {
            DnsServer                 = 'localhost'
            EnablePollutionProtection = $false
        }
    }
}

<#
    .SYNOPSIS
        Test the property EnablePollutionProtection setting to $true.
#>
configuration DnsServerCache_EnablePollutionProtection_Config
{
    Import-DscResource -ModuleName 'xDnsServer'

    node $AllNodes.NodeName
    {
        DnsServerCache 'Integration_Test'
        {
            DnsServer                 = 'localhost'
            EnablePollutionProtection = $true
        }
    }
}

<#
    .SYNOPSIS
        Test the property StoreEmptyAuthenticationResponse setting to $false.
#>
configuration DnsServerCache_DisableStoreEmptyAuthenticationResponse_Config
{
    Import-DscResource -ModuleName 'xDnsServer'

    node $AllNodes.NodeName
    {
        DnsServerCache 'Integration_Test'
        {
            DnsServer                        = 'localhost'
            StoreEmptyAuthenticationResponse = $false
        }
    }
}

<#
    .SYNOPSIS
        Test the property EnablePollutionProtection setting to $true.
#>
configuration DnsServerCache_EnableStoreEmptyAuthenticationResponse_Config
{
    Import-DscResource -ModuleName 'xDnsServer'

    node $AllNodes.NodeName
    {
        DnsServerCache 'Integration_Test'
        {
            DnsServer                        = 'localhost'
            StoreEmptyAuthenticationResponse = $true
        }
    }
}
