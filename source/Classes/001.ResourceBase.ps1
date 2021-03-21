<#
    .SYNOPSIS
        A class with methods that are equal for all class-based resources.

    .DESCRIPTION
       A class with methods that are equal for all class-based resources.

    .NOTES
        This class should not contain any DSC properties.
#>

class ResourceBase
{
    # Hidden property for holding localization strings
    hidden [System.Collections.Hashtable] $localizedData = @{}

    # Default constructor
    ResourceBase()
    {
        Assert-Module -ModuleName 'DnsServer'

        $localizedDataFileName = ('{0}.strings.psd1' -f $this.GetType().Name)

        $this.localizedData = Get-LocalizedData -DefaultUICulture 'en-US' -FileName $localizedDataFileName
    }

    [ResourceBase] Get([Microsoft.Management.Infrastructure.CimInstance] $CommandProperties)
    {
        $dscResourceObject = [System.Activator]::CreateInstance($this.GetType())

        foreach ($propertyName in $this.PSObject.Properties.Name)
        {
            if ($propertyName -in @($CommandProperties.PSObject.Properties.Name))
            {
                $dscResourceObject.$propertyName = $CommandProperties.$propertyName
            }
        }

        # Always set this as it won't be in the $CommandProperties
        $dscResourceObject.DnsServer = $this.DnsServer

        return $dscResourceObject
    }

    [void] Set()
    {
    }

    [System.Boolean] Test()
    {
        $isInDesiredState = $true

        <#
            Returns all enforced properties not in desires state, or $null if
            all enforced properties are in desired state.
        #>
        $propertiesNotInDesiredState = $this.Compare()

        if ($propertiesNotInDesiredState)
        {
            $isInDesiredState = $false
        }

        return $isInDesiredState
    }

    # Returns a hashtable containing all properties that should be enforced.
    hidden [System.Collections.Hashtable[]] Compare()
    {
        $currentState = $this.Get() | ConvertTo-HashTableFromObject
        $desiredState = $this | ConvertTo-HashTableFromObject

        # Remove properties that have $null as the value.
        @($desiredState.Keys) | ForEach-Object -Process {
            $isReadProperty = $this.GetType().GetMember($_).CustomAttributes.Where( { $_.NamedArguments.MemberName -eq 'NotConfigurable' }).NamedArguments.TypedValue.Value -eq $true

            # Also remove read properties so that there is no chance to campare those.
            if ($isReadProperty -or $null -eq $desiredState[$_])
            {
                $desiredState.Remove($_)
            }
        }

        $CompareDscParameterState = @{
            CurrentValues     = $currentState
            DesiredValues     = $desiredState
            Properties        = $desiredState.Keys
            ExcludeProperties = @('DnsServer')
            IncludeValue      = $true
        }

        <#
            Returns all enforced properties not in desires state, or $null if
            all enforced properties are in desired state.
        #>
        return (Compare-DscParameterState @CompareDscParameterState)
    }

    # Returns a hashtable containing all properties that should be enforced.
    hidden [System.Collections.Hashtable] GetDesiredStateForSplatting([System.Collections.Hashtable[]] $Properties)
    {
        $desiredState = @{}

        $Properties | ForEach-Object -Process {
            $desiredState[$_.Property] = $_.ExpectedValue
        }

        return $desiredState
    }
}
