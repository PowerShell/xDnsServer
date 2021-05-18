$ConfigurationData = @{
    AllNodes = @(
        @{
            NodeName             = 'localhost'
            CertificateFile      = $env:DscPublicCertificatePath
            DnsServer            = 'localhost'
            DisjointNets         = $false
            NoForwarderRecursion = $false
            LogLevel             = 0
        }
    )
}

Configuration DSC_DnsServerSettingLegacy_SetSettings_config
{
    Import-DscResource -ModuleName 'DnsServerDsc'

    node $AllNodes.NodeName
    {
        DnsServerSettingLegacy 'Integration_Test'
        {

            DnsServer            = $Node.DnsServer
            DisjointNets         = $Node.DisjointNets
            NoForwarderRecursion = $Node.NoForwarderRecursion
            LogLevel             = $Node.LogLevel
        }
    }
}
