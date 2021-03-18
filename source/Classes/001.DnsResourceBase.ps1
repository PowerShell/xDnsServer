<#
    .SYNOPSIS
        A class with DSC properties that are equal for all class-based resources.

    .DESCRIPTION
       A class with DSC properties that are equal for all class-based resources.

    .PARAMETER DnsServer
        Name of the DnsServer on which to create the record.
#>

class ResourceBase
{
    [DscProperty()]
    [System.String]
    $DnsServer = 'localhost'

    # Default constructor
    DnsRecordBase()
    {
    }
}
