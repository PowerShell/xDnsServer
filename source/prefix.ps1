# Import nested, 'DnsServerDsc.Common' module
$script:dnsServerDscCommonModulePath = Join-Path -Path $PSScriptRoot -ChildPath 'Modules\DnsServerDsc.Common'
Import-Module -Name $script:dnsServerDscCommonModulePath

# Import nested, 'DscResource.Common' module
$script:dscResourceCommonModulePath = Join-Path -Path $PSScriptRoot -ChildPath 'Modules\DscResource.Common'
Import-Module -Name $script:dscResourceCommonModulePath
