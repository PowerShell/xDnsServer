<#
    .SYNOPSIS
        The DnsRecordSrv DSC resource manages SRV DNS records against a specific zone on a Domain Name System (DNS) server.

    .DESCRIPTION
        The DnsRecordSrv DSC resource manages SRV DNS records against a specific zone on a Domain Name System (DNS) server.

    .PARAMETER SymbolicName
        Service name for the SRV record. eg: xmpp, ldap, etc. (Key Parameter)

    .PARAMETER Protocol
        Service transmission protocol ('TCP' or 'UDP') (Key Parameter)

    .PARAMETER Port
        The TCP or UDP port on which the service is found (Key Parameter)

    .PARAMETER Target
        Specifies the Target Hostname or IP Address. (Key Parameter)

    .PARAMETER Priority
        Specifies the Priority value of the SRV record. (Mandatory Parameter)

    .PARAMETER Weight
        Specifies the weight of the SRV record. (Mandatory Parameter)
#>

[DscResource()]
class DnsRecordSrv : DnsRecordBase
{
    [DscProperty(Key)]
    [System.String]
    $SymbolicName

    [DscProperty(Key)]
    [ValidateSet('TCP', 'UDP')]
    [System.String]
    $Protocol

    [DscProperty(Key)]
    [ValidateRange(1, 65535)]
    [System.UInt16]
    $Port

    [DscProperty(Key)]
    [System.String]
    $Target

    [DscProperty(Mandatory)]
    [System.UInt16]
    $Priority

    [DscProperty(Mandatory)]
    [System.UInt16]
    $Weight

    hidden [System.String] getRecordHostName()
    {
        return "_$($this.SymbolicName)._$($this.Protocol)".ToLower()
    }

    hidden [System.String] getRecordHostName($aSymbolicName, $aProtocol)
    {
        return "_$($aSymbolicName)._$($aProtocol)".ToLower()
    }

    [DnsRecordSrv] Get()
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
        $recordHostName = $this.getRecordHostName()

        Write-Verbose -Message ($this.localizedData.GettingDnsRecordMessage -f $recordHostName, $this.target, 'SRV', $this.ZoneName, $this.ZoneScope, $this.DnsServer)

        $dnsParameters = @{
            Name         = $recordHostName
            ZoneName     = $this.ZoneName
            ComputerName = $this.DnsServer
            RRType       = 'SRV'
        }

        if ($this.isScoped)
        {
            $dnsParameters['ZoneScope'] = $this.ZoneScope
        }

        $record = Get-DnsServerResourceRecord @dnsParameters -ErrorAction SilentlyContinue | Where-Object -FilterScript {
            $_.HostName -eq $recordHostName -and
            $_.RecordData.Port -eq $this.Port -and
            $_.RecordData.DomainName -eq "$($this.Target)."
        }

        return $record
    }

    hidden [DnsRecordSrv] NewDscResourceObjectFromRecord([Microsoft.Management.Infrastructure.CimInstance] $record)
    {
        $dscResourceObject = [DnsRecordSrv] @{
            ZoneName     = $this.ZoneName
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
        $recordHostName = $this.getRecordHostName()

        $dnsParameters = @{
            ZoneName     = $this.ZoneName
            ComputerName = $this.DnsServer
            Name         = $recordHostName
            Srv          = $true
            DomainName   = $this.Target
            Port         = $this.Port
            Priority     = $this.Priority
            Weight       = $this.Weight
        }

        if ($this.isScoped)
        {
            $dnsParameters['ZoneScope'] = $this.ZoneScope
        }

        if ($null -ne $this.TimeToLive)
        {
            $dnsParameters.Add('TimeToLive', $this.TimeToLive)
        }

        Write-Verbose -Message ($this.localizedData.CreatingDnsRecordMessage -f 'SRV', $recordHostName, $this.Target, $this.ZoneName, $this.ZoneScope, $this.DnsServer)

        Add-DnsServerResourceRecord @dnsParameters
    }

    hidden [void] ModifyResourceRecord([Microsoft.Management.Infrastructure.CimInstance] $existingRecord, [System.Collections.Hashtable[]] $propertiesNotInDesiredState)
    {
        $recordHostName = $this.getRecordHostName()

        $dnsParameters = @{
            ZoneName     = $this.ZoneName
            ComputerName = $this.DnsServer
        }

        if ($this.isScoped)
        {
            $dnsParameters['ZoneScope'] = $this.ZoneScope
        }

        # Copy the existing record and modify values as appropriate
        $newRecord = [Microsoft.Management.Infrastructure.CimInstance]::new($existingRecord)

        foreach ($propertyToChange in $propertiesNotInDesiredState)
        {
            switch ($propertyToChange.Property)
            {
                # Key parameters will never be affected, so only include Mandatory and Optional values in the switch statement
                'Priority'
                {
                    $newRecord.RecordData.Priority = $propertyToChange.ExpectedValue
                }

                'Weight'
                {
                    $newRecord.RecordData.Weight = $propertyToChange.ExpectedValue
                }

                'TimeToLive'
                {
                    $newRecord.TimeToLive = [System.TimeSpan] $propertyToChange.ExpectedValue
                }

            }
        }

        Set-DnsServerResourceRecord @dnsParameters -OldInputObject $existingRecord -NewInputObject $newRecord -Verbose
    }
}
