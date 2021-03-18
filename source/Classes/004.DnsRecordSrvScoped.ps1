<#
    .SYNOPSIS
        The DnsRecordSrvScoped DSC resource manages SRV DNS records against a specific zone and zone scope on a Domain Name System (DNS) server.

    .DESCRIPTION
        The DnsRecordSrvScoped DSC resource manages SRV DNS records against a specific zone and zone scope on a Domain Name System (DNS) server.

    .PARAMETER ZoneScope
        Specifies the name of a zone scope. (Key Parameter)
#>

[DscResource()]
class DnsRecordSrvScoped : DnsRecordSrv
{
    [DscProperty(Key)]
    [System.String]
    $ZoneScope

    [DnsRecordSrvScoped] Get()
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
        return ([DnsRecordSrv] $this).GetResourceRecord()
    }

    hidden [DnsRecordSrvScoped] NewDscResourceObjectFromRecord([Microsoft.Management.Infrastructure.CimInstance] $record)
    {
        $dscResourceObject = [DnsRecordSrvScoped] @{
            ZoneName     = $this.ZoneName
            ZoneScope    = $this.ZoneScope
            SymbolicName = $this.SymbolicName
            Protocol     = $this.Protocol.ToLower()
            Port         = $this.Port
            Target       = ($record.RecordData.DomainName).TrimEnd('.')
            Priority     = $record.RecordData.Priority
            Weight       = $record.RecordData.Weight
            TimeToLive   = $record.TimeToLive.ToString()
            DnsServer    = $this.DnsServer
            Ensure       = 'Present'
        }

        return $dscResourceObject
    }

    hidden [void] AddResourceRecord()
    {
        ([DnsRecordSrv] $this).AddResourceRecord()
    }

    hidden [void] ModifyResourceRecord([Microsoft.Management.Infrastructure.CimInstance] $existingRecord, [System.Collections.Hashtable[]] $propertiesNotInDesiredState)
    {
        ([DnsRecordSrv] $this).ModifyResourceRecord($existingRecord, $propertiesNotInDesiredState)
    }
}
