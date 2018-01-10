Configuration MSFT_xDnsRecord_Config
{
    Import-DscResource -ModuleName xDnsServer

    node localhost 
    {
        WindowsFeature InstallDns
        {
            Name = 'DNS'
            Ensure = 'Present'
            IncludeAllSubFeature = $true
        }

        xDnsRecord TestA_Record
        {
            Name = "TestA"
            Target = "192.168.0.123"
            Zone = "contoso.com"
            Type = "ARecord"                    
            Ensure = 'Present'
            DependsOn = '[WindowsFeature]InstallDns'
        }

        xDnsRecord TestCname_Record
        {
            Name = "TestCNAME"
            Target = "test.contoso.com"
            Zone = "contoso.com"
            Type = "CName"    
            Ensure = 'Present'
            DependsOn = '[WindowsFeature]InstallDns'
        }

        xDnsRecord TestPtr_Record
        {
            Name = "123"
            Target = "TestA.contoso.com"
            Zone = "0.168.192.in-addr.arpa"
            Type = "PTR"    
            Ensure = 'Present'
            DependsOn = '[WindowsFeature]InstallDns'
        }
    }
}
