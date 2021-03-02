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
            DefaultAgingState         = $false
            DefaultNoRefreshInterval  = 168
            DefaultRefreshInterval    = 168
            DisableAutoReverseZones   = $false
            DisjointNets              = $false
            DsPollingInterval         = 180
            DsTombstoneInterval       = 1209600
            EDnsCacheTimeout          = 900
            EnableDirectoryPartitions = $true
            EnableDnsSec              = 1
            EnableEDnsProbes          = $true
            ForwardDelegations        = 0
            Forwarders                = @('168.63.129.16')
            ForwardingTimeout         = 3
            IsSlave                   = $false
            <#
                At least one of the listening IP addresses that is specified must
                be present on a network interface on the host running the test.
            #>
            ListenAddresses           = @($firstIpAddress, '10.0.0.10')
            LocalNetPriority          = $true
            LogLevel                  = 0
            LooseWildcarding          = $false
            MaxCacheTTL               = 86400
            MaxNegativeCacheTTL       = 900
            NameCheckFlag             = 2
            NoRecursion               = $true
            RecursionRetry            = 3
            RecursionTimeout          = 8
            RoundRobin                = $true
            RpcProtocol               = 5
            ScavengingInterval        = 168
            SecureResponses           = $true
            SendPort                  = 0
            StrictFileParsing         = $false
            UpdateOptions             = 783
            WriteAuthorityNS          = $false
            XfrConnectTimeout         = 30
        }
    )
}

Configuration MSFT_xDnsServerSetting_SetSettings_config
{

    Import-DscResource -ModuleName 'xDnsServer'

    node $AllNodes.NodeName
    {
        xDnsServerSetting 'Integration_Test'
        {

            DnsServer                 = $Node.DnsServer
            AddressAnswerLimit        = $Node.AddressAnswerLimit
            AllowUpdate               = $Node.AllowUpdate
            AutoCacheUpdate           = $Node.AutoCacheUpdate
            AutoConfigFileZones       = $Node.AutoConfigFileZones
            BindSecondaries           = $Node.BindSecondaries
            BootMethod                = $Node.BootMethod
            DefaultAgingState         = $Node.DefaultAgingState
            DefaultNoRefreshInterval  = $Node.DefaultNoRefreshInterval
            DefaultRefreshInterval    = $Node.DefaultRefreshInterval
            DisableAutoReverseZones   = $Node.DisableAutoReverseZones
            DisjointNets              = $Node.DisjointNets
            DsPollingInterval         = $Node.DsPollingInterval
            DsTombstoneInterval       = $Node.DsTombstoneInterval
            EDnsCacheTimeout          = $Node.EDnsCacheTimeout
            EnableDirectoryPartitions = $Node.EnableDirectoryPartitions
            EnableDnsSec              = $Node.EnableDnsSec
            EnableEDnsProbes          = $Node.EnableEDnsProbes
            ForwardDelegations        = $Node.ForwardDelegations
            Forwarders                = $Node.Forwarders
            ForwardingTimeout         = $Node.ForwardingTimeout
            IsSlave                   = $Node.IsSlave
            ListenAddresses           = $Node.ListenAddresses
            LocalNetPriority          = $Node.LocalNetPriority
            LogLevel                  = $Node.LogLevel
            LooseWildcarding          = $Node.LooseWildcarding
            MaxCacheTTL               = $Node.MaxCacheTTL
            MaxNegativeCacheTTL       = $Node.MaxNegativeCacheTTL
            NameCheckFlag             = $Node.NameCheckFlag
            NoRecursion               = $Node.NoRecursion
            RecursionRetry            = $Node.RecursionRetry
            RecursionTimeout          = $Node.RecursionTimeout
            RoundRobin                = $Node.RoundRobin
            RpcProtocol               = $Node.RpcProtocol
            ScavengingInterval        = $Node.ScavengingInterval
            SecureResponses           = $Node.SecureResponses
            SendPort                  = $Node.SendPort
            StrictFileParsing         = $Node.StrictFileParsing
            UpdateOptions             = $Node.UpdateOptions
            WriteAuthorityNS          = $Node.WriteAuthorityNS
            XfrConnectTimeout         = $Node.XfrConnectTimeout
        }
    }
}
