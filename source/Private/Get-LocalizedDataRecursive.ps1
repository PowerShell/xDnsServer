<#
    .SYNOPSIS
        Get the localization strings data from one or more localization string files.
        This can be used in classes to be able to inherit localization strings
        from one or more base class.

        If a localization string key exist in a parent class's localization string
        file it will override the localization string key in any base class.

    .PARAMETER ClassName
       An array of class names, normally provided by `Get-ClassName -Recursive`.

    .OUTPUTS
        Returns a string array with at least one item.
#>
function Get-LocalizedDataRecursive
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [System.String[]]
        $ClassName
    )

    begin
    {
        $localizedData = @{}
    }

    process
    {
        foreach ($name in $ClassName)
        {
            if ($name -match '\.psd1')
            {
                # Assume we got full file name.
                $localizationFileName = $name
            }
            else
            {
                # Assume we only got class name.
                $localizationFileName = '{0}.strings.psd1' -f $name
            }

            Write-Debug -Message ('Importing localization data from {0}' -f $localizationFileName)

            # Get localized data for the class
            $classLocalizationStrings = Get-LocalizedData -DefaultUICulture 'en-US' -FileName $localizationFileName -ErrorAction 'Stop'

            # Append only previously unspecified keys in the localization data
            foreach ($key in $classLocalizationStrings.Keys)
            {
                if (-not $localizedData.ContainsKey($key))
                {
                    $localizedData[$key] = $classLocalizationStrings[$key]
                }
            }
        }
    }

    end
    {
        Write-Debug -Message ('Localization data: {0}' -f ($localizedData | ConvertTo-JSON))

        return $localizedData
    }
}
