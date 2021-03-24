<#
    .SYNOPSIS
        The DnsServerScavenging DSC resource manages _extension mechanisms for DNS (EDNS)_
        on a Microsoft Domain Name System (DNS) server.

    .DESCRIPTION
        The DnsServerScavenging DSC resource manages _extension mechanisms for DNS (EDNS)_
        on a Microsoft Domain Name System (DNS) server.

    .PARAMETER DnsServer
        The host name of the Domain Name System (DNS) server, or use `'localhost'`
        for the current node.

    .PARAMETER CacheTimeout
        Specifies the number of seconds that the DNS server caches EDNS information.

    .PARAMETER EnableProbes
        Specifies whether to enable the server to probe other servers to determine
        whether they support EDNS.

    .PARAMETER EnableReception
        Specifies whether the DNS server accepts queries that contain an EDNS record.
#>

[DscResource()]
class DnsServerEDns : ResourceBase
{
    [DscProperty(Key)]
    [System.String]
    $DnsServer

    [DscProperty()]
    [System.String]
    $CacheTimeout

    [DscProperty()]
    [Nullable[System.Boolean]]
    $EnableProbes

    [DscProperty()]
    [Nullable[System.Boolean]]
    $EnableReception

    [DnsServerEDns] Get()
    {
        Write-Verbose -Message ($this.localizedData.GetCurrentState -f $this.DnsServer)

        $getDnsServerEDnsParameters = @{}

        if ($this.DnsServer -ne 'localhost')
        {
            $getDnsServerEDnsParameters['ComputerName'] = $this.DnsServer
        }

        $getDnsServerEDnsResult = Get-DnsServerEDns @getDnsServerEDnsParameters

        # Call the base method to return the properties.
        return ([ResourceBase] $this).Get($getDnsServerEDnsResult)
    }

    [void] Set()
    {
        $this.AssertProperties()

        Write-Verbose -Message ($this.localizedData.SetDesiredState -f $this.DnsServer)

        # Call the base method to get enforced properties that are not in desired state.
        $propertiesNotInDesiredState = $this.Compare()

        if ($propertiesNotInDesiredState)
        {
            $setDnsServerEDnsParameters = $this.GetDesiredStateForSplatting($propertiesNotInDesiredState)

            $setDnsServerEDnsParameters.Keys | ForEach-Object -Process {
                Write-Verbose -Message ($this.localizedData.SetProperty -f $_, $setDnsServerEDnsParameters.$_)
            }

            if ($this.DnsServer -ne 'localhost')
            {
                $setDnsServerEDnsParameters['ComputerName'] = $this.DnsServer
            }

            Set-DnsServerEDns @setDnsServerEDnsParameters
        }
        else
        {
            Write-Verbose -Message $this.localizedData.NoPropertiesToSet
        }
    }

    [System.Boolean] Test()
    {
        $this.AssertProperties()

        Write-Verbose -Message ($this.localizedData.TestDesiredState -f $this.DnsServer)

        # Call the base method to test all of the properties that should be enforced.
        $isInDesiredState = ([ResourceBase] $this).Test()

        if ($isInDesiredState)
        {
            Write-Verbose -Message ($this.localizedData.InDesiredState -f $this.DnsServer)
        }
        else
        {
            Write-Verbose -Message ($this.localizedData.NotInDesiredState -f $this.DnsServer)
        }

        return $isInDesiredState
    }

    hidden [void] AssertProperties()
    {
        @(
            'CacheTimeout'
        ) | ForEach-Object -Process {
            $valueToConvert = $this.$_

            # Only evaluate properties that have a value.
            if ($null -ne $valueToConvert)
            {
                Assert-TimeSpan -PropertyName $_ -Value $valueToConvert -Minimum '0.00:00:00'
            }
        }
    }
}
