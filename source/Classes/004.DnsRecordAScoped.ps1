<#
    .SYNOPSIS
        The DnsRecordAScoped DSC resource manages A DNS records against a specific zone and zone scope on a Domain Name System (DNS) server.

    .DESCRIPTION
        The DnsRecordAScoped DSC resource manages A DNS records against a specific zone and zone scope on a Domain Name System (DNS) server.

    .PARAMETER ZoneScope
        Specifies the name of a zone scope. (Key Parameter)
#>

[DscResource()]
class DnsRecordAScoped : DnsRecordA
{
    [DscProperty(Key)]
    [System.String]
    $ZoneScope

    [DnsRecordAScoped] Get()
    {
        return ([DnsRecordBase] $this).Get()
    }

    [void] Set()
    {
        ([DnsRecordBase] $this).Set()
    }

    [System.Boolean] Test()
    {
        return ([DnsRecordBase] $this).Test()
    }

    hidden [Microsoft.Management.Infrastructure.CimInstance] GetResourceRecord()
    {
        return ([DnsRecordA] $this).GetResourceRecord()
    }

    hidden [DnsRecordAScoped] NewDscResourceObjectFromRecord([Microsoft.Management.Infrastructure.CimInstance] $record)
    {
        $dscResourceObject = [DnsRecordAScoped] @{
            ZoneName    = $this.ZoneName
            ZoneScope   = $this.ZoneScope
            Name        = $this.Name
            IPv4Address = $this.IPv4Address
            TimeToLive  = $record.TimeToLive.ToString()
            DnsServer   = $this.DnsServer
            Ensure      = 'Present'
        }

        return $dscResourceObject
    }

    hidden [void] AddResourceRecord()
    {
        ([DnsRecordA] $this).AddResourceRecord()
    }

    hidden [void] ModifyResourceRecord([Microsoft.Management.Infrastructure.CimInstance] $existingRecord, [System.Collections.Hashtable[]] $propertiesNotInDesiredState)
    {
        ([DnsRecordA] $this).ModifyResourceRecord($existingRecord, $propertiesNotInDesiredState)
    }
}
