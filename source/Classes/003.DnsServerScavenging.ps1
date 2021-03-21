<#
    .SYNOPSIS
        The DnsServerScavenging DSC resource manages scavenging on a Microsoft
        Domain Name System (DNS) server.

    .DESCRIPTION
        The DnsServerScavenging DSC resource manages scavenging on a Microsoft
        Domain Name System (DNS) server.

    .PARAMETER DnsServer
        The host name of the Domain Name System (DNS) server, or use 'localhost'
        for the current node.

    .PARAMETER ScavengingState
        Specifies whether to Enable automatic scavenging of stale records.
        `ScavengingState` determines whether the DNS scavenging feature is enabled
        by default on newly created zones.

    .PARAMETER ScavengingInterval
        Specifies a length of time as a value that can be converted to a `[TimeSpan]`
        object. `ScavengingInterval` determines whether the scavenging feature for
        the DNS server is enabled and sets the number of hours between scavenging
        cycles. The value `0` disables scavenging for the DNS server. A setting
        greater than `0` enables scavenging for the server and sets the number of
        days, hours, minutes, and seconds (formatted as dd.hh:mm:ss) between
        scavenging cycles. The minimum value is 0. The maximum value is 365.00:00:00
        (1 year).

    .PARAMETER RefreshInterval
        Specifies the refresh interval as a value that can be converted to a `[TimeSpan]`
        object (formatted as dd.hh:mm:ss). During this interval, a DNS server can
        refresh a resource record that has a non-zero time stamp. Zones on the server
        inherit this value automatically. If a DNS server does not refresh a resource
        record that has a non-zero time stamp, the DNS server can remove that record
        during the next scavenging. Do not select a value smaller than the longest
        refresh period of a resource record registered in the zone. The minimum value
        is `0`. The maximum value is 365.00:00:00 (1 year).

    .PARAMETER NoRefreshInterval
        Specifies a length of time as a value that can be converted to a `[TimeSpan]`
        object (formatted as dd.hh:mm:ss). `NoRefreshInterval` sets a period of time
        in which no refreshes are accepted for dynamically updated records. Zones on
        the server inherit this value automatically. This value is the interval between
        the last update of a timestamp for a record and the earliest time when the
        timestamp can be refreshed. The minimum value is 0. The maximum value is
        365.00:00:00 (1 year).

    .PARAMETER LastScavengeTime
        The time when the last scavenging cycle was executed.
#>

[DscResource()]
class DnsServerScavenging : ResourceBase
{
    [DscProperty(Key)]
    [System.String]
    $DnsServer

    [DscProperty()]
    [Nullable[System.Boolean]]
    $ScavengingState

    [DscProperty()]
    [System.String]
    $ScavengingInterval

    [DscProperty()]
    [System.String]
    $RefreshInterval

    [DscProperty()]
    [System.String]
    $NoRefreshInterval

    [DscProperty(NotConfigurable)]
    [Nullable[System.DateTime]]
    $LastScavengeTime

    # Default constructor.
    DnsServerScavenging() : base ()
    {
    }

    [DnsServerScavenging] Get()
    {
        Write-Verbose -Message ($this.localizedData.GetCurrentState -f $this.DnsServer)

        $getDnsServerScavengingParameters = @{}

        if ($this.DnsServer -ne 'localhost')
        {
            $getDnsServerScavengingParameters['ComputerName'] = $this.DnsServer
        }

        $getDnsServerScavengingResult = Get-DnsServerScavenging @getDnsServerScavengingParameters

        # Call the base method to return the properties.
        return [DnsServerScavenging] ([ResourceBase] $this).Get($getDnsServerScavengingResult)
    }

    [void] Set()
    {
        $this.AssertProperties()

        Write-Verbose -Message ($this.localizedData.SetDesiredState -f $this.DnsServer)

        # Call the base method to get enforced properties that are not in desired state.
        $propertiesNotInDesiredState = $this.Compare()

        if ($propertiesNotInDesiredState)
        {
            $setDnsServerScavengingParameters = $this.GetDesiredStateForSplatting($propertiesNotInDesiredState)

            $setDnsServerScavengingParameters.Keys | ForEach-Object -Process {
                Write-Verbose -Message ($this.localizedData.SetProperty -f $_, $setDnsServerScavengingParameters.$_)
            }

            if ($this.DnsServer -ne 'localhost')
            {
                $setDnsServerScavengingParameters['ComputerName'] = $this.DnsServer
            }

            Set-DnsServerScavenging @setDnsServerScavengingParameters
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
            'ScavengingInterval'
            'RefreshInterval'
            'NoRefreshInterval'
        ) | ForEach-Object -Process {
            $valueToConvert = $this.$_

            # Only evaluate properties that have a value.
            if ($null -ne $valueToConvert)
            {
                $timeSpanObject = $valueToConvert | ConvertTo-TimeSpan

                # If the conversion fails $null is returned.
                if ($null -eq $timeSpanObject)
                {
                    $errorMessage = $this.localizedData.PropertyHasWrongFormat -f $_, $valueToConvert

                    New-InvalidOperationException -Message $errorMessage
                }

                if ($timeSpanObject -gt [System.TimeSpan] '365.00:00:00')
                {
                    $errorMessage = $this.localizedData.TimeSpanExceedMaximumValue -f $_, $timeSpanObject.ToString()

                    New-InvalidOperationException -Message $errorMessage
                }
            }
        }
    }
}
