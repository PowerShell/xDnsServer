<#
    .SYNOPSIS
        The localized resource strings in English (en-US) for the
        resource DnsServerScavenging.
#>

ConvertFrom-StringData @'
    GetCurrentState = Getting the current state of the extension mechanisms for DNS (EDNS) settings for the server '{0}'. (DSS0001)
    TestDesiredState = Determining the current state of the extension mechanisms for DNS (EDNS) settings for the server '{0}'. (DSS0002)
    SetDesiredState = Setting the desired state for the extension mechanisms for DNS (EDNS) settings for the server '{0}'. (DSS0003)
    NotInDesiredState = The extension mechanisms for DNS (EDNS) settings for the server '{0}' is not in desired state. (DSS0004)
    InDesiredState = The extension mechanisms for DNS (EDNS) settings for the server '{0}' is in desired state. (DSS0005)
    SetProperty = The extension mechanisms for DNS (EDNS) property '{0}' will be set to '{1}'. (DSS0006)
    NoPropertiesToSet = All properties are in desired state. (DSS0009)
'@
