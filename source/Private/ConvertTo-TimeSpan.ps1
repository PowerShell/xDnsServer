<#
    .SYNOPSIS
        Converts a string value to a TimeSpan object.

    .PARAMETER Value
       The time value as a string that should be converted.

    .OUTPUTS
        Returns an TimeSpan object containing the converted value, or $null if
        conversion was not possible.
#>
function ConvertTo-TimeSpan
{
    [CmdletBinding()]
    [OutputType([System.TimeSpan])]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [System.String]
        $Value
    )

    $timeSpan = New-TimeSpan

    if (-not [System.TimeSpan]::TryParse($Value, [ref] $timeSpan))
    {
        $timeSpan = $null
    }

    return $timeSpan
}
