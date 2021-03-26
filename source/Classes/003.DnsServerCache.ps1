<#
    .SYNOPSIS
        The DnsServerCache DSC resource manages cache settings on a Microsoft Domain
        Name System (DNS) server.

    .DESCRIPTION
        The DnsServerCache DSC resource manages cache settings on a Microsoft Domain
        Name System (DNS) server.

    .PARAMETER DnsServer
        The host name of the Domain Name System (DNS) server, or use `'localhost'`
        for the current node.

    .PARAMETER IgnorePolicies
        Specifies whether to ignore policies for this cache.

    .PARAMETER LockingPercent
        Specifies a percentage of the original Time to Live (TTL) value that caching
        can consume. Cache locking is configured as a percent value. For example, if
        the cache locking value is set to `50`, the DNS server does not overwrite a
        cached entry for half of the duration of the TTL. If the cache locking percent
        is set to `100` that means the DNS server will not overwrite cached entries
        for the entire duration of the TTL.

    .PARAMETER MaxKBSize
        Specifies the maximum size, in kilobytes, of the memory cache of a DNS server.
        If set to `0` there is no limit.

    .PARAMETER MaxNegativeTtl
        Specifies how long an entry that records a negative answer to a query remains
        stored in the DNS cache. Minimum value is `'00:00:01'` and maximum value is
        `'30.00:00:00'`

    .PARAMETER MaxTtl
        Specifies how long a record is saved in cache. Minimum value is `'00:00:00'`
        and maximum value is `'30.00:00:00'`. If the TimeSpan is set to `'00:00:00'`
        (0 seconds), the DNS server does not cache records.

    .PARAMETER EnablePollutionProtection
        Specifies whether DNS filters name service (NS) resource records that are
        cached. Valid values are False (`$false`), which caches all responses to name
        queries; and True (`$true`), which caches only the records that belong to the
        same DNS subtree.

        When you set this parameter value to False (`$false`), cache pollution
        protection is disabled. A DNS server caches the Host (A) record and all queried
        NS resources that are in the DNS server zone. In this case, DNS can also cache
        the NS record of an unauthorized DNS server. This event causes name resolution
        to fail or to be appropriated for subsequent queries in the specified domain.

        When you set the value for this parameter to True (`$true`), the DNS server
        enables cache pollution protection and ignores the Host (A) record. The DNS
        server performs a cache update query to resolve the address of the NS if the
        NS is outside the zone of the DNS server. The additional query minimally
        affects DNS server performance.

    .PARAMETER StoreEmptyAuthenticationResponse
        Specifies whether a DNS server stores empty authoritative responses in the
        cache (RFC-2308).
#>

[DscResource()]
class DnsServerCache : ResourceBase
{
    [DscProperty(Key)]
    [System.String]
    $DnsServer

    [DscProperty()]
    [Nullable[System.Boolean]]
    $IgnorePolicies

    [DscProperty()]
    [Nullable[System.UInt32]]
    $LockingPercent

    [DscProperty()]
    [Nullable[System.UInt32]]
    $MaxKBSize

    [DscProperty()]
    [System.String]
    $MaxNegativeTtl

    [DscProperty()]
    [System.String]
    $MaxTtl

    [DscProperty()]
    [Nullable[System.Boolean]]
    $EnablePollutionProtection

    [DscProperty()]
    [Nullable[System.Boolean]]
    $StoreEmptyAuthenticationResponse

    [DnsServerCache] Get()
    {
        Write-Verbose -Message ($this.localizedData.GetCurrentState -f $this.DnsServer)

        $getDnsServerCacheParameters = @{}

        if ($this.DnsServer -ne 'localhost')
        {
            $getDnsServerCacheParameters['ComputerName'] = $this.DnsServer
        }

        $getDnsServerCacheResult = Get-DnsServerCache @getDnsServerCacheParameters

        # Call the base method to return the properties.
        return ([ResourceBase] $this).Get($getDnsServerCacheResult)
    }

    [void] Set()
    {
        $this.AssertProperties()

        Write-Verbose -Message ($this.localizedData.SetDesiredState -f $this.DnsServer)

        # Call the base method to get enforced properties that are not in desired state.
        $propertiesNotInDesiredState = $this.Compare()

        if ($propertiesNotInDesiredState)
        {
            $setDnsServerCacheParameters = $this.GetDesiredStateForSplatting($propertiesNotInDesiredState)

            $setDnsServerCacheParameters.Keys | ForEach-Object -Process {
                Write-Verbose -Message ($this.localizedData.SetProperty -f $_, $setDnsServerCacheParameters.$_)
            }

            if ($this.DnsServer -ne 'localhost')
            {
                $setDnsServerCacheParameters['ComputerName'] = $this.DnsServer
            }

            <#
                If the property 'EnablePollutionProtection' was present and not in desired state,
                then the property name must be change for the cmdlet Set-DnsServerCache. In the
                cmdlet Get-DnsServerCache the property name is 'EnablePollutionProtection', but
                in the cmdlet Set-DnsServerCache the parameter is 'PollutionProtection'.
            #>
            if ($setDnsServerCacheParameters.ContainsKey('EnablePollutionProtection'))
            {
                $setDnsServerCacheParameters['PollutionProtection'] = $setDnsServerCacheParameters.EnablePollutionProtection

                $setDnsServerCacheParameters.Remove('EnablePollutionProtection')
            }

            Set-DnsServerCache @setDnsServerCacheParameters
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
        if ($null -ne $this.MaxNegativeTtl)
        {
            Assert-TimeSpan -PropertyName 'MaxNegativeTtl' -Value $this.MaxNegativeTtl -Minimum '0.00:00:01' -Maximum '30.00:00:00'
        }

        if ($null -ne $this.MaxTtl)
        {
            Assert-TimeSpan -PropertyName 'MaxTtl' -Value $this.MaxTtl -Minimum '0.00:00:00' -Maximum '30.00:00:00'
        }
    }
}
