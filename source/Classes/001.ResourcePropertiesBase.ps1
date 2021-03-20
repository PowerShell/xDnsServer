<#
    .SYNOPSIS
        A class with DSC properties that are equal for all class-based resources.

    .DESCRIPTION
       A class with DSC properties that are equal for all class-based resources.

    .PARAMETER DnsServer
        The host name of the Domain Name System (DNS) server, or use 'localhost'
        for the current node. Defaults to `'localhost'`.
#>

class ResourcePropertiesBase
{
    [DscProperty()]
    [System.String]
    $DnsServer = 'localhost'

    # Default constructor
    ResourcePropertiesBase()
    {
    }
}
