$availableIpAddresses = Get-NetIPInterface -AddressFamily IPv4 -Dhcp Disabled |
    Get-NetIPAddress |
    Where-Object IPAddress -ne ([IPAddress]::Loopback)

Write-Verbose -Message ('Available IPv4 network interfaces on build worker: {0}' -f (($availableIpAddresses | Select-Object -Property IPAddress, InterfaceAlias, AddressFamily) | Out-String)) -Verbose

$firstIpAddress = $availableIpAddresses | Select-Object -ExpandProperty IPAddress -First 1

Write-Verbose -Message ('Using IP address ''{0}'' for the integration test as first listening IP address.' -f $firstIpAddress) -Verbose

$ConfigurationData = @{
    AllNodes = @(
        @{
            NodeName                  = 'localhost'
            CertificateFile           = $env:DscPublicCertificatePath
            DnsServer                 = 'localhost'
            AddressAnswerLimit        = 0
            AllowUpdate               = 1
            AutoCacheUpdate           = $false
            AutoConfigFileZones       = 1
            BindSecondaries           = $false
            BootMethod                = 3
            DisableAutoReverseZone    = $false
            DisjointNets              = $false
            EnableDirectoryPartitions = $true
            EnableDnsSec              = 1
            ForwardDelegations        = 0
            IsSlave                   = $false
            <#
                At least one of the listening IP addresses that is specified must
                be present on a network interface on the host running the test.
            #>
            ListeningIPAddress        = @($firstIpAddress, '10.0.0.10')
            LocalNetPriority          = $true
            LogLevel                  = 0
            LooseWildcarding          = $false
            NameCheckFlag             = 2
            RoundRobin                = $true
            RpcProtocol               = 5
            SendPort                  = 0
            StrictFileParsing         = $false
            UpdateOptions             = 783
            WriteAuthorityNS          = $false
            XfrConnectTimeout         = 30
        }
    )
}

Configuration DSC_DnsServerSetting_SetSettings_config
{

    Import-DscResource -ModuleName 'DnsServerDsc'

    node $AllNodes.NodeName
    {
        DnsServerSetting 'Integration_Test'
        {

            DnsServer                 = $Node.DnsServer
            AddressAnswerLimit        = $Node.AddressAnswerLimit
            AllowUpdate               = $Node.AllowUpdate
            AutoCacheUpdate           = $Node.AutoCacheUpdate
            AutoConfigFileZones       = $Node.AutoConfigFileZones
            BindSecondaries           = $Node.BindSecondaries
            BootMethod                = $Node.BootMethod
            DisableAutoReverseZone    = $Node.DisableAutoReverseZone
            DisjointNets              = $Node.DisjointNets
            EnableDirectoryPartitions = $Node.EnableDirectoryPartitions
            EnableDnsSec              = $Node.EnableDnsSec
            ForwardDelegations        = $Node.ForwardDelegations
            IsSlave                   = $Node.IsSlave
            ListeningIPAddress        = $Node.ListeningIPAddress
            LocalNetPriority          = $Node.LocalNetPriority
            LogLevel                  = $Node.LogLevel
            LooseWildcarding          = $Node.LooseWildcarding
            NameCheckFlag             = $Node.NameCheckFlag
            RoundRobin                = $Node.RoundRobin
            RpcProtocol               = $Node.RpcProtocol
            SendPort                  = $Node.SendPort
            StrictFileParsing         = $Node.StrictFileParsing
            UpdateOptions             = $Node.UpdateOptions
            WriteAuthorityNS          = $Node.WriteAuthorityNS
            XfrConnectTimeout         = $Node.XfrConnectTimeout
        }
    }
}
