<#
    .SYNOPSIS
        The localized resource strings in English (en-US) for the
        resource DnsServerScavenging.
#>

ConvertFrom-StringData @'
    GetCurrentState = Getting the current state of the scavenging settings for the server '{0}'. (DSS0001)
    TestDesiredState = Determining the current state of the scavenging settings for the server '{0}'. (DSS0002)
    SetDesiredState = Setting the desired state for the scavenging settings for the server '{0}'. (DSS0003)
    NotInDesiredState = The scavenging settings for the server '{0}' is not in desired state. (DSS0004)
    InDesiredState = The scavenging settings for the server '{0}' is in desired state. (DSS0005)
    SetProperty = The scavenging property '{0}' will be set to '{1}'. (DSS0006)
    PropertyHasWrongFormat = The property '{0}' has the value '{1}' that cannot be converted to [System.TimeSpan]. (DSS0007)
    TimeSpanExceedMaximumValue = The property '{0}' has the value '{1}' that exceeds the maximum value of '365.00:00:00'. (DSS0007)
'@
