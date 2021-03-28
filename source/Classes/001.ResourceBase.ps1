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

        $this.localizedData = Get-LocalizedDataRecursive -ClassName ($this | Get-ClassName -Recurse)
    }

    [ResourceBase] Get()
    {
        Write-Verbose -Message ($this.localizedData.GetCurrentState -f $this.DnsServer)

        # Get all key properties.
        $keyProperty = $this |
            Get-Member -MemberType 'Property' |
            Select-Object -ExpandProperty Name |
            Where-Object -FilterScript {
                $this.GetType().GetMember($_).CustomAttributes.Where( { $_.NamedArguments.MemberName -eq 'Key' }).NamedArguments.TypedValue.Value -eq $true
            }

        $getParameters = @{}

        # Set each key property to its value (property DnsServer is handled below).
        $keyProperty |
            Where-Object -FilterScript {
                $_ -ne 'DnsServer'
            } |
            ForEach-Object -Process {
                $getParameters[$_] = $this.$_
            }

        # Set ComputerName depending on value of DnsServer.
        if ($this.DnsServer -ne 'localhost')
        {
            $getParameters['ComputerName'] = $this.DnsServer
        }

        $getCurrentStateResult = $this.GetCurrentState($getParameters)

        # Call the overloaded method Get() to get the properties to return.
        return ([ResourceBase] $this).Get($getCurrentStateResult)
    }

    <#
        This overloaded method should be merged together with Get() above when
        no resource uses it directly.
    #>
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
        $this.AssertProperties()

        Write-Verbose -Message ($this.localizedData.SetDesiredState -f $this.DnsServer)

        # Call the Compare method to get enforced properties that are not in desired state.
        $propertiesNotInDesiredState = $this.Compare()

        if ($propertiesNotInDesiredState)
        {
            $setDnsServerRecursionParameters = $this.GetDesiredStateForSplatting($propertiesNotInDesiredState)

            $setDnsServerRecursionParameters.Keys | ForEach-Object -Process {
                Write-Verbose -Message ($this.localizedData.SetProperty -f $_, $setDnsServerRecursionParameters.$_)
            }

            if ($this.DnsServer -ne 'localhost')
            {
                $setDnsServerRecursionParameters['ComputerName'] = $this.DnsServer
            }

            <#
                Call the Modify() method with the properties that should be enforced
                and was not in desired state.
            #>
            $this.Modify($setDnsServerRecursionParameters)
        }
        else
        {
            Write-Verbose -Message $this.localizedData.NoPropertiesToSet
        }
    }

    [System.Boolean] Test()
    {
        Write-Verbose -Message ($this.localizedData.TestDesiredState -f $this.DnsServer)

        $this.AssertProperties()

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

        if ($isInDesiredState)
        {
            Write-Verbose -Message ($this.localizedData.InDesiredState -f $this.DnsServer)
        }
        else
        {
            Write-Verbose -Message ($this.localizedData.NotInDesiredState -f $this.DnsServer)
        }

        return $isInDesiredState
    }

    <#
        Returns a hashtable containing all properties that should be enforced.
        This method should normally not be overridden.
    #>
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

    # This method can be overridden if resource specific asserts are needed.
    hidden [void] AssertProperties()
    {
    }

    # This method must be overridden by a resource.
    hidden [void] Modify([System.Collections.Hashtable] $properties)
    {
        throw $this.localizedData.ModifyMethodNotImplemented
    }

    # This method must be overridden by a resource.
    hidden [Microsoft.Management.Infrastructure.CimInstance] GetCurrentState([System.Collections.Hashtable] $properties)
    {
        throw $this.localizedData.GetCurrentStateMethodNotImplemented
    }
}
