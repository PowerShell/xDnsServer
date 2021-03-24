<#
    .SYNOPSIS
        Assert that the value provided can be converted to a TimeSpan object.

    .PARAMETER Value
       The time value as a string that should be converted.
#>
function Assert-TimeSpan
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [System.String]
        $Value,

        [Parameter(Mandatory = $true)]
        [System.String]
        $PropertyName,

        [Parameter()]
        [System.TimeSpan]
        $Maximum,

        [Parameter()]
        [System.TimeSpan]
        $Minimum
    )

    $timeSpanObject = $Value | ConvertTo-TimeSpan

    # If the conversion fails $null is returned.
    if ($null -eq $timeSpanObject)
    {
        $errorMessage = $script:localizedData.PropertyHasWrongFormat -f $PropertyName, $Value

        New-InvalidOperationException -Message $errorMessage
    }

    if ($PSBoundParameters.ContainsKey('Maximum') -and $timeSpanObject -gt $Maximum)
    {
        $errorMessage = $script:localizedData.TimeSpanExceedMaximumValue -f $PropertyName, $timeSpanObject.ToString(), $Maximum

        New-InvalidOperationException -Message $errorMessage
    }

    if ($PSBoundParameters.ContainsKey('Minimum') -and $timeSpanObject -lt $Minimum)
    {
        $errorMessage = $script:localizedData.TimeSpanBelowMinimumValue -f $PropertyName, $timeSpanObject.ToString(), $Minimum

        New-InvalidOperationException -Message $errorMessage
    }
}
