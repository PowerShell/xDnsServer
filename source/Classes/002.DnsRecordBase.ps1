<#
    .SYNOPSIS
        A DSC Resource for MS DNS Server that is not exposed to end users representing the common fields available to all resource records.

    .DESCRIPTION
        A DSC Resource for MS DNS Server that is not exposed to end users representing the common fields available to all resource records.

    .PARAMETER ZoneName
        Specifies the name of a DNS zone. (Key Parameter)

    .PARAMETER TimeToLive
        Specifies the TimeToLive value of the SRV record. Value must be in valid TimeSpan string format (i.e.: Days.Hours:Minutes:Seconds.Miliseconds or 30.23:59:59.999).

    .PARAMETER Ensure
        Whether the host record should be present or removed.
#>

class DnsRecordBase : ResourcePropertiesBase
{
    [DscProperty(Key)]
    [System.String]
    $ZoneName

    [DscProperty()]
    [System.String]
    $TimeToLive

    [DscProperty()]
    [Ensure]
    $Ensure = [Ensure]::Present

    # Hidden property to determine whether the class is a scoped version
    hidden [System.Boolean] $isScoped

    # Hidden property for holding localization strings
    hidden [System.Collections.Hashtable] $localizedData

    # Hidden method to integrate localized strings from classes up the inheritance stack
    hidden [void] SetLocalizedData()
    {
        # Create a list of the inherited class names
        $inheritedClasses = @(,$this.GetType().Name)
        $parentClass = $this.GetType().BaseType
        while ($parentClass -ne [ResourcePropertiesBase])
        {
            $inheritedClasses += $parentClass.Name
            $parentClass = $parentClass.BaseType
        }

        $this.localizedData = @{}

        foreach ($className in $inheritedClasses)
        {
            # Get localized data for the class
            $localizationFile = "$($className).strings.psd1"

            try
            {
                $tmpData = Get-LocalizedData -DefaultUICulture 'en-US' -FileName $localizationFile -ErrorAction Stop

                # Append only previously unspecified keys in the localization data
                foreach ($key in $tmpData.Keys)
                {
                    if (-not $this.localizedData.ContainsKey($key))
                    {
                        $this.localizedData[$key] = $tmpData[$key]
                    }
                }
            }
            catch
            {
                if ($_.CategoryInfo.Category.ToString() -eq 'ObjectNotFound')
                {
                    Write-Warning $_.Exception.Message
                }
                else
                {
                    throw $_
                }
            }
        }

        Write-Debug ($this.localizedData | ConvertTo-JSON)
    }

    # Default constructor sets the $isScoped variable and loads the localization strings
    DnsRecordBase()
    {
        # Determine scope
        $this.isScoped = $this.PSObject.Properties.Name -contains 'ZoneScope'

        # Import the localization strings
        $this.SetLocalizedData()
    }

    #region Generic DSC methods -- DO NOT OVERRIDE

    [DnsRecordBase] Get()
    {
        Write-Verbose -Message ($this.localizedData.GettingDscResourceObject -f $this.GetType().Name)

        $dscResourceObject = $null

        $record = $this.GetResourceRecord()

        if ($null -eq $record)
        {
            Write-Verbose -Message $this.localizedData.RecordNotFound

            <#
                Create an object of the correct type (i.e.: the subclassed resource type)
                and set its values to those specified in the object, but set Ensure to Absent
            #>
            $dscResourceObject = [System.Activator]::CreateInstance($this.GetType())

            foreach ($propertyName in $this.PSObject.Properties.Name)
            {
                $dscResourceObject.$propertyName = $this.$propertyName
            }

            $dscResourceObject.Ensure = 'Absent'
        }
        else
        {
            Write-Verbose -Message $this.localizedData.RecordFound

            # Build an object reflecting the current state based on the record found
            $dscResourceObject = $this.NewDscResourceObjectFromRecord($record)
        }

        return $dscResourceObject
    }

    [void] Set()
    {
        # Initialize dns cmdlet Parameters for removing a record
        $dnsParameters = @{
            ZoneName     = $this.ZoneName
            ComputerName = $this.DnsServer
        }

        # Accomodate for scoped records as well
        if ($this.isScoped)
        {
            $dnsParameters['ZoneScope'] = ($this.PSObject.Properties | Where-Object -FilterScript { $_.Name -eq 'ZoneScope' }).Value
        }

        $existingRecord = $this.GetResourceRecord()

        if ($this.Ensure -eq 'Present')
        {
            if ($null -ne $existingRecord)
            {
                $currentState = $this.Get() | ConvertTo-HashTableFromObject
                $desiredState = $this | ConvertTo-HashTableFromObject

                # Remove properties that have $null as the value
                @($desiredState.Keys) | ForEach-Object -Process {
                    if ($null -eq $desiredState[$_])
                    {
                        $desiredState.Remove($_)
                    }
                }

                # Returns all enforced properties not in desires state, or $null if all enforced properties are in desired state
                $propertiesNotInDesiredState = Compare-DscParameterState -CurrentValues $currentState -DesiredValues $desiredState -Properties $desiredState.Keys -IncludeValue

                if ($null -ne $propertiesNotInDesiredState)
                {
                    Write-Verbose -Message $this.localizedData.ModifyingExistingRecord

                    $this.ModifyResourceRecord($existingRecord, $propertiesNotInDesiredState)
                }
            }
            else
            {
                Write-Verbose -Message ($this.localizedData.AddingNewRecord -f $this.GetType().Name)

                # Adding record
                $this.AddResourceRecord()
            }
        }
        elseif ($this.Ensure -eq 'Absent')
        {
            if ($null -ne $existingRecord)
            {
                Write-Verbose -Message $this.localizedData.RemovingExistingRecord

                # Removing existing record
                $existingRecord | Remove-DnsServerResourceRecord @dnsParameters -Force
            }
        }
    }

    [System.Boolean] Test()
    {
        $isInDesiredState = $true

        $currentState = $this.Get() | ConvertTo-HashTableFromObject
        $desiredState = $this | ConvertTo-HashTableFromObject

        if ($this.Ensure -eq 'Present')
        {
            if ($currentState.Ensure -eq 'Present')
            {
                # Remove properties that have $null as the value
                @($desiredState.Keys) | ForEach-Object -Process {
                    if ($null -eq $desiredState[$_])
                    {
                        $desiredState.Remove($_)
                    }
                }

                # Returns all enforced properties not in desires state, or $null if all enforced properties are in desired state
                $propertiesNotInDesiredState = Compare-DscParameterState -CurrentValues $currentState -DesiredValues $desiredState -Properties $desiredState.Keys -ExcludeProperties @('Ensure')

                if ($propertiesNotInDesiredState)
                {
                    $isInDesiredState = $false
                }
            }
            else
            {
                Write-Verbose -Message ($this.localizedData.PropertyIsNotInDesiredState -f 'Ensure', $desiredState['Ensure'], $currentState['Ensure'])

                $isInDesiredState = $false
            }
        }

        if ($this.Ensure -eq 'Absent')
        {
            if ($currentState['Ensure'] -eq 'Present')
            {
                Write-Verbose -Message ($this.localizedData.PropertyIsNotInDesiredState -f 'Ensure', $desiredState['Ensure'], $currentState['Ensure'])

                $isInDesiredState = $false
            }
        }

        if ($isInDesiredState)
        {
            Write-Verbose -Message $this.localizedData.ObjectInDesiredState
        }
        else
        {
            Write-Verbose -Message $this.localizedData.ObjectNotInDesiredState
        }

        return $isInDesiredState
    }

    #endregion

    #region Methods to override

    # Using the values supplied to $this, query the DNS server for a resource record and return it
    hidden [Microsoft.Management.Infrastructure.CimInstance] GetResourceRecord()
    {
        throw $this.localizedData.GetResourceRecordNotImplemented
    }

    # Add a resource record using the properties of this object.
    hidden [void] AddResourceRecord()
    {
        throw $this.localizedData.AddResourceRecordNotImplemented
    }

    <#
        Modifies a resource record using the properties of this object.

        The data in each hashtable will contain the following properties:

        - ActualType (System.RuntimeType)
        - ExpectedType (System.RuntimeType)
        - Property (String)
        - ExpectedValue (the property's type)
        - ActualValue (the property's type)
        - InDesiredState (System.Boolean)
    #>
    hidden [void] ModifyResourceRecord([Microsoft.Management.Infrastructure.CimInstance] $existingRecord, [System.Collections.Hashtable[]] $propertiesNotInDesiredState)
    {
        throw $this.localizedData.ModifyResourceRecordNotImplemented
    }

    # Given a resource record object, create an instance of this class with the appropriate data
    hidden [DnsRecordBase] NewDscResourceObjectFromRecord($record)
    {
        throw $this.localizedData.NewResourceObjectFromRecordNotImplemented
    }

    #endregion
}
