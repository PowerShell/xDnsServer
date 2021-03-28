<#
    .SYNOPSIS
        The localized resource strings in English (en-US) for the
        class ResourceBase.
#>

ConvertFrom-StringData @'
    GetCurrentState = Getting the current state of {0} for the server '{1}'. (RB0001)
    TestDesiredState = Determining the current state of {0} for the server '{1}'. (RB0002)
    SetDesiredState = Setting the desired state of {0} for the server '{1}'. (RB0003)
    NotInDesiredState = The {0} for the server '{1}' is not in desired state. (RB0004)
    InDesiredState = The {0} for the server '{1}' is in desired state. (RB0005)
    SetProperty = The {0} property '{1}' will be set to '{2}'. (RB0006)
    NoPropertiesToSet = All properties are in desired state. (RB0007)
    ModifyMethodNotImplemented = An override for the method Modify() is not implemented in the resource. (RB0008)
    GetCurrentStateMethodNotImplemented = An override for the method GetCurrentState() is not implemented in the resource. (RB0009)
'@
