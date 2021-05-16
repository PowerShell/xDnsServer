# Change log for DnsServerDsc

The format is based on and uses the types of changes according to [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Removed

- xDnsRecord
  - BREAKING CHANGE: The resource has been replaced by _DnsServerA_, _DnsServerPtr_,
  and _DnsServerCName_ ([issue #221](https://github.com/dsccommunity/DnsServerDsc/issues/221)).
- xDnsServerMx
  - BREAKING CHANGE: The resource has been replaced by _DnsServerMx_ ([issue #228](https://github.com/dsccommunity/DnsServerDsc/issues/228)).
- DnsServerSetting
  - BREAKING CHANGE: The properties `Forwarders` and `ForwardingTimeout` has
    been removed ([issue #192](https://github.com/dsccommunity/DnsServerDsc/issues/192)).
    Use the resource _DnsServerForwarder_ to enforce these properties.
  - BREAKING CHANGE: The properties `EnableEDnsProbes` and `EDnsCacheTimeout` has
    been removed ([issue #195](https://github.com/dsccommunity/DnsServerDsc/issues/195)).
    Use the resource _DnsServerEDns_ to enforce these properties.
  - BREAKING CHANGE: The properties `SecureResponses`, `MaxCacheTTL`, and
    `MaxNegativeCacheTTL` has been removed ([issue #197](https://github.com/dsccommunity/DnsServerDsc/issues/197)).
    To enforce theses properties, use resource _DnsServerEDns_ using the
    properties `EnablePollutionProtection`, `MaxTtl`, and `MaxNegativeTtl`
    respectively.
  - BREAKING CHANGE: The properties `DefaultAgingState`, `ScavengingInterval`,
    `DefaultNoRefreshInterval`, and `DefaultRefreshInterval` have been removed.
    Use the resource _DnsServerScavenging_ to enforce this properties ([issue #193](https://github.com/dsccommunity/DnsServerDsc/issues/193)).
  - BREAKING CHANGE: The properties `NoRecursion`, `RecursionRetry`, and
    `RecursionTimeout` has been removed ([issue #200](https://github.com/dsccommunity/DnsServerDsc/issues/200)).
    To enforce theses properties, use resource _DnsServerRecursion_ using the
    properties `Enable`, `RetryInterval`, and `Timeout` respectively.
- ResourceBase
  - For the method `Get()` the overload that took a `[Microsoft.Management.Infrastructure.CimInstance]`
    was removed as it is not the correct pattern going forward.

### Added

- DnsServerDsc
  - Added new resource
    - _DnsServerCache_ - resource to enforce cache settings ([issue #196](https://github.com/dsccommunity/DnsServerDsc/issues/196)).
    - _DnsServerRecursion_ - resource to enforce recursion settings ([issue #198](https://github.com/dsccommunity/DnsServerDsc/issues/198)).
  - Added new private function `Get-ClassName` that returns the class name
    or optionally an array with the class name and all inherited base class
    named.
  - Added new private function `Get-LocalizedDataRecursive` that gathers
    all localization strings from an array of class names. This can be used
    in classes to be able to inherit localization strings from one or more
    base class. If a localization string key exist in a parent class's
    localization string file it will override the localization string key
    in any base class.
  - Fixed code coverage in the pipeline ([issue #246](https://github.com/dsccommunity/DnsServerDsc/issues/246)).
- ResourceBase
  - Added new method `Assert()` tha calls `Assert-Module` and `AssertProperties()`.
- DnsRecordNs
  - Added new resource to manage NS records
- DnsRecordNsScoped
  - Added new resource to manage scoped NS records

### Changed

- DnsServerDsc
  - BREAKING CHANGE: Renamed the module to DnsServerDsc ([issue #179](https://github.com/dsccommunity/DnsServerDsc/issues/179)).
  - BREAKING CHANGE: Removed the prefix 'x' from all MOF-based resources
    ([issue #179](https://github.com/dsccommunity/DnsServerDsc/issues/179)).
  - Renamed a MOF-based resource to use the prefix 'DSC' ([issue #225](https://github.com/dsccommunity/DnsServerDsc/issues/225)).
  - Fix stub `Get-DnsServerResourceRecord` so it throws if it is not mocked
    correctly ([issue #204](https://github.com/dsccommunity/DnsServerDsc/issues/204)).
  - Switch the order in the deploy pipeline so that creating the GitHub release
    is made after a successful release.
  - Updated stub functions to throw if they are used (when missing a mock in
    unit test) ([issue #235](https://github.com/dsccommunity/DnsServerDsc/issues/235)).
- ResourceBase
  - Added support for inherit localization strings and also able to override
    a localization string that exist in a base class.
  - Moved more logic from the resources into the base class for the method
    `Test()`, `Get()`, and `Set()`. The base class now have three methods
    `AssertProperties()`, `Modify()`, and `GetCurrentState()` where the
    two latter ones must be overridden by a resource if calling the base
    methods `Set()` and `Get()`.
  - Moved the `Assert-Module` from the constructor to a new method `Assert()`
    that is called from `Get()`, `Test()`, and `Set()`. The method `Assert()`
    also calls the method `AssertProperties()`. The method `Assert()` is not
    meant to be overridden, but can if there is a reason not to run
    `Assert-Module` and or `AssertProperties()`.
- Integration tests
  - Added commands in the DnsRecord* integration tests to wait for the LCM
    before moving to the next test.
- DnsServerCache
  - Moved to the same coding pattern as _DnsServerRecursion_.
- DnsServerEDns
  - Moved to the same coding pattern as _DnsServerRecursion_.
- DnsServerScavenging
  - Moved to the same coding pattern as _DnsServerRecursion_.
- xDnsServerSetting
  - Changed to use `Get-DnsServerSetting` and `Set-DnsServerSetting`
    ([issue #185](https://github.com/dsccommunity/xDnsServer/issues/185)).
  - BREAKING CHANGE: The property `DisableAutoReverseZones` have been renamed
    to `DisableAutoReverseZone`.
  - BREAKING CHANGE: The property `ListenAddresses` have been renamed
    to `ListeningIPAddress`.

### Fixed

- Logic bug in DnsRecordPtr.expandIPv6String($string) (#255)
  - Supporting tests added

## [2.0.0] - 2021-03-26

### Deprecated

- **The module _xDnsServer_ will be renamed _DnsServerDsc_. Version `2.0.0`
  will be the the last release of _xDnsServer_. Version `3.0.0` will be
  release as _DnsServerDsc_, it will be released shortly after the `2.0.0`
  release** ([issue #179](https://github.com/dsccommunity/DnsServerDsc/issues/179)).
  The prefix 'x' will be removed from all resources in _DnsServerDsc_.
- xDnsRecord will be removed in the next release (of DnsServerDsc) ([issue #220](https://github.com/dsccommunity/DnsServerDsc/issues/220)).
  Start migrate to the resources _DnsRecord*_.
- xDnsRecordMx will be removed in the next release (of DnsServerDsc) ([issue #228](https://github.com/dsccommunity/DnsServerDsc/issues/228)).
  Start migrate to the resources _DnsRecordMx_.
- The properties `DefaultAgingState`, `ScavengingInterval`, `DefaultNoRefreshInterval`,
  and `DefaultRefreshInterval` will be removed from the resource xDnsServerSetting
  in the next release (of DnsServerDsc) ([issue #193](https://github.com/dsccommunity/DnsServerDsc/issues/193)).
  Migrate to use the resource _DnsServerScavenging_ to enforce these properties.
- The properties `EnableEDnsProbes` and `EDnsCacheTimeout` will be removed from
  the resource xDnsServerSetting in the next release (of DnsServerDsc) ([issue #195](https://github.com/dsccommunity/DnsServerDsc/issues/195)).
  Migrate to use the resource _DnsServerEDns_ to enforce these properties.
- The properties `Forwarders` and `ForwardingTimeout` will be removed from the
  resource xDnsServerSetting in the next release (of DnsServerDsc) ([issue #192](https://github.com/dsccommunity/DnsServerDsc/issues/192))
  Migrate to use the resource _xDnsServerForwarder_ to enforce these properties.

### Added

- xDnsServer
  - Added automatic release with a new CI pipeline.
  - Add unit tests for the Get-LocalizedData, NewTerminatingError, and
    Assert-Module helper functions.
  - Added description README files for each resource.
  - Add example files for resources
  - OptIn to the following Dsc Resource Meta Tests:
    - Common Tests - Validate Localization
    - Common Tests - Validate Example Files To Be Published
  - Standardize Resource Localization.
  - Added the build task `Publish_GitHub_Wiki_Content` to publish content
    to the GitHub repository wiki.
  - Added new source folder `WikiSource` which content will be published
    to the GitHub repository wiki.
    - Add the markdown file `Home.md` which will be automatically updated
      with the latest version before published to GitHub repository wiki.
  - Updated the prerequisites in the GitHub repository wiki (`Home.md`)
    that _Microsoft DNS Server_ is required on a node targeted by a resource,
    and that the DSC resources requires the [DnsServer](https://docs.microsoft.com/en-us/powershell/module/dnsserver)
    PowerShell module ([issue #37](https://github.com/dsccommunity/DnsServerDsc/issues/37)).
  - Added the base class `ResourcePropertiesBase` to hold DSC properties that
    can be inherited for all class-based resources.
  - Added the base class `ResourceBase` to hold methods that should be
    inherited for all class-based resources.
  - Added new private function `ConvertTo-TimeSpan` to help when evaluating
    properties that must be passed as strings and then converted to `[System.TimeSpan]`.
  - Added new private function `Assert-TimeSpan` to help assert that a value
    provided in a resource can be converted to a `[System.TimeSpan]` and
    optionally evaluates so it is not below a minium value or over a maximum
    value.
  - Added `prefix.ps1` that is used to import dependent modules like _DscResource.Common_.
  - Added new resource
    - _DnsServerScavenging_ - resource to enforce scavenging settings ([issue #189](https://github.com/dsccommunity/DnsServerDsc/issues/189)).
    - _DnsServerEDns_ - resource to enforce extension mechanisms for DNS
      (EDNS) settings ([issue #194](https://github.com/dsccommunity/DnsServerDsc/issues/194)).
- xDNSServerClientSubnet
  - Added integration tests.
- DnsServerPrimaryZone
  - Added integration tests ([issue #173](https://github.com/dsccommunity/DnsServerDsc/issues/173)).
  - Added more examples.
- xDnsRecordMx
  - Added new resource to manage MX records
- xDnsServerZoneScope
  - Added integration tests ([issue #177](https://github.com/dsccommunity/DnsServerDsc/issues/177)).
  - New read-only property `ZoneFile` was added to return the zone scope
    file name used for the zone scope.
- xDnsServerZoneAging
  - Added integration tests ([issue #176](https://github.com/dsccommunity/DnsServerDsc/issues/176)).
- xDnsServerForwarder
  - Added integration tests ([issue #170](https://github.com/dsccommunity/DnsServerDsc/issues/170)).
  - Added new properties `Timeout` and `EnableReordering` ([issue #191](https://github.com/dsccommunity/DnsServerDsc/issues/191)).
- xDnsServerRootHint
  - Added integration tests ([issue #174](https://github.com/dsccommunity/DnsServerDsc/issues/174)).
- Added a class `DnsRecordBase` that is used as the base class for the resources that create DNS records.
  - Added unit tests to get code coverage on unimplemented method calls (ensuring the `throw` statements get called)
- DnsRecordSrv
  - Added new resource to manage SRV records
- DnsRecordSrvScoped
  - Added new resource to manage scoped SRV records
- DnsRecordA
  - Added new resource to manage A records
- DnsRecordAScoped
  - Added new resource to manage scoped A records
- DnsRecordAaaa
  - Added new resource to manage AAAA records
- DnsRecordAaaaScoped
  - Added new resource to manage scoped AAAA records
- DnsRecordCname
  - Added new resource to manage CNAME records
- DnsRecordCnameScoped
  - Added new resource to manage scoped CNAME records
- DnsRecordPtr
  - Added new resource to manage PTR records
- DnsRecordMx
  - Added new resource to manage MX records
- DnsRecordMxScoped
  - Added new resource to manage scoped MX records

### Changed

- xDnsServer
  - BREAKING CHANGE: Set the minimum required PowerShell version to 5.0 to support classes used in the DnsRecordBase-derived resources.
  - Resolve style guideline violations for hashtables
  - Update pipeline files.
  - Renamed the default branch to `main` ([issue #131](https://github.com/dsccommunity/DnsServerDsc/issues/131)).
  - Uses `PublishPipelineArtifact` in  _Azure Pipelines_ pipeline.
  - Unit tests are now run in PowerShell 7 in the _Azure Pipelines_
    pipeline ([issue #160](https://github.com/dsccommunity/DnsServerDsc/issues/160)).
  - Merged the historic changelog into CHANGELOG.md ([issue #163](https://github.com/dsccommunity/DnsServerDsc/issues/163)).
  - Only add required role in integration tests pipeline.
  - Updated the pipeline to use new deploy tasks.
  - Revert back to using the latest version of module Sampler for the pipeline ([issue #211](https://github.com/dsccommunity/DnsServerDsc/issues/211)).
  - Fixed the sections in the GitHub issue and pull request templates to
    have a bit higher font size. This makes it easier to distinguish the
    section headers from the text.
- DnsRecordBase
  - Changed class to inherit properties from 'ResourcePropertiesBase`.
- xDnsRecordSrv
  - Now uses `[CimInstance]::new()` both in the resource code and the resource
    unit test to clone the existing DNS record instead of using the method
    `Clone()` that does not exist in PowerShell 7.
- xDnsServerSetting
  - BREAKING CHANGE: The mandatory parameter was replaced by the mandatory
    parameter `DnsServer`. This prevents the resource from being used twice
    in the same configuration using the same value for the parameter `DnsServer`
    ([issue #156](https://github.com/dsccommunity/DnsServerDsc/issues/156)).
- xDnsServerDiagnostics
  - BREAKING CHANGE: The mandatory parameter was replaced by the mandatory
    parameter `DnsServer`. This prevents the resource from being used twice
    in the same configuration using the same value for the parameter `DnsServer`
    ([issue #157](https://github.com/dsccommunity/DnsServerDsc/issues/157)).
- DnsServerPrimaryZone
  - Now the property `Name` is always returned from `Get-TargetResource`
    since it is a `Key` property.
- xDnsServerForwarder
  - When providing an empty collection the resource will enforce that no
    forwarders are present.
- DnsRecordSrv
  - Changed logic for calculating the record's hostname

### Removed

- xDnsServer
  - BREAKING CHANGE: The DSC resource xDnsARecord was removed and are replaced
    by the DSC resource xDnsRecord.
  - Removing resource parameter information from README.md in favor of
    GitHub repository wiki.
  - Remove helper function `Remove-CommonParameter` in favor of the one in
    module _DscResource.Common_ ([issue #166](https://github.com/dsccommunity/DnsServerDsc/issues/166)).
  - Remove helper function `ConvertTo-CimInstance` in favor of the one in
    module _DscResource.Common_ ([issue #167](https://github.com/dsccommunity/DnsServerDsc/issues/167)).
  - Remove helper function `ConvertTo-HashTable` in favor of the one in
    module _DscResource.Common_ ([issue #168](https://github.com/dsccommunity/DnsServerDsc/issues/168)).
- xDnsServerSetting
  - BREAKING CHANGE: The properties `LogIPFilterList`, `LogFilePath`, `LogFileMaxSize`,
    and `EventLogLevel` have been removed. Use the resource _xDnsServerDiagnostics_
    with the properties `FilterIPAddressList`, `LogFilePath`, `MaxMBFileSize`,
    and `EventLogLevel` respectively to enforce these settings ([issue #190](https://github.com/dsccommunity/DnsServerDsc/issues/190)).
    This is done in preparation to support more settings through the cmdlet
    `Get-DnsServerSetting` for the resource _xDnsServerSetting_, and these
    values are not available through that cmdlet.

### Fixed

- xDnsServer
  - Enable Unit Tests to be run locally.
  - Rename integration tests so they are run in the pipeline ([issue #134](https://github.com/dsccommunity/DnsServerDsc/issues/134)).
  - Added back the build task to create releases on GitHub.
  - Fixed property descriptions in schema throughout.
  - Fixed uploading of code coverage that was broken since Sampler had a bug.
  - Fixed examples so the license information point to the correct default branch.
  - Fixed a link in the README.md.
- DnsRecordBase
  - Fixed so that `Compare-DscParameterState` is used in the method `Test()`
    if the record already exist, to compare the properties except `Ensure`
    in the desired state against the actual state ([issue #205](https://github.com/dsccommunity/DnsServerDsc/issues/205)).
- xDnsServerDiagnostics
  - Fix EnableLogFileRollover Parameter name in README.
- xDnsRecord
  - Fix "Removing a DNS A Record" example.
- xDnsServerDiagnostics
  - Fixed typo in parameter `EnableLogFileRollover`.
  - Updated integration test to correct template.
- xDnsServerSettings
  - Updated integration test to correct template.
- xDnsServerAdZone
  - Now the parameter `ComputerName` can be used without throwing an exception
    ([issue 79](https://github.com/PowerShell/DnsServerDsc/issues/79)).
- xDnsServerZoneScope
  - Correctly returns the zone scope name when calling `Get-TargetResource`.
- xDnsServerForwarder
  - Now it is possible to just enforce the property `UseRooHint` without
    changing forwarders.
- xDnsServerRootHint
  - Fixed the verbose message returning the correct number of root hints.

## [1.16.0.0] - 2019-10-30

- Changes to xDnsServerADZone
  - Raise an exception if `DirectoryPartitionName` is specified and
    `ReplicationScope` is not `Custom`. ([issue #110](https://github.com/dsccommunity/DnsServerDsc/issues/110)).
  - Enforce the `ReplicationScope` parameter being passed to `Set-DnsServerPrimaryZone`
    if `DirectoryPartitionName` has changed.
- xDnsServer:
  - OptIn to the following Dsc Resource Meta Tests:
    - Common Tests - Relative Path Length
    - Common Tests - Validate Markdown Links
    - Common Tests - Custom Script Analyzer Rules
    - Common Tests - Required Script Analyzer Rules
    - Common Tests - Flagged Script Analyzer Rules

## [1.15.0.0] - 2019-09-18

- Fixed: Ignore UseRootHint in xDnsServerForwarder test function if it was not
  specified in the resource [Claudio Spizzi (@claudiospizzi)](https://github.com/claudiospizzi)

## [1.14.0.0] - 2019-08-07

- Copied enhancements to Test-DscParameterState from NetworkingDsc
- Put the helper module to its own folder
- Copied enhancements to Test-DscParameterState from NetworkingDsc
- Put the helper module to its own folder
- Added xDnsServerRootHint resource
- Added xDnsServerClientSubnet resource
- Added xDnsServerZoneScope resource

## [1.13.0.0] - 2019-06-26

- Added resource xDnsServerConditionalForwarder
- Added xDnsServerDiagnostics resource to this module.

## [1.12.0.0] - 2019-05-15

- Update appveyor.yml to use the default template.
- Added default template files .codecov.yml, .gitattributes, and .gitignore,
  and .vscode folder.
- Added UseRootHint property to xDnsServerForwarder resource.

## [1.11.0.0] - 2018-06-13

- Changes to xDnsServer
  - Updated appveyor.yml to use the default template and add CodeCov support
    ([issue #73](https://github.com/PowerShell/xActiveDirectory/issues/73)).
  - Adding a Branches section to the README.md with Codecov badges for both
    master and dev branch ([issue #73](https://github.com/PowerShell/xActiveDirectory/issues/73)).
  - Updated description of resource module in README.md.
- Added resource xDnsServerZoneAging. [Claudio Spizzi (@claudiospizzi)](https://github.com/claudiospizzi)
- Changes to DnsServerPrimaryZone
  - Fix bug in Get-TargetResource that caused the Zone Name to be null
    ([issue #63](https://github.com/dsccommunity/DnsServerDsc/issues/63)).
    [Brandon Padgett (@gerane)](https://github.com/gerane)
- Changes to xDnsRecord
  - Added Ptr record support (partly resolves issue #34).
    [Reggie Gibson (@regedit32)](https://github.com/regedit32)

## [1.10.0.0] - 2018-05-02

- Changes to xDnsServerADZone
  - Fixed bug introduced by [PR #49](https://github.com/dsccommunity/DnsServerDsc/pull/49).
    Previously, CimSessions were always used regardless of connecting to a
    remote machine or the local machine.  Now CimSessions are only utilized
    when a computername, or computername and credential are used ([issue #53](https://github.com/dsccommunity/DnsServerDsc/issues/53)).
  [Michael Fyffe (@TraGicCode)](https://github.com/TraGicCode)
- Fixed all PSSA rule warnings. [Michael Fyffe (@TraGicCode)](https://github.com/TraGicCode)
- Fix DsAvailable key missing ([#66](https://github.com/dsccommunity/DnsServerDsc/issues/66)).
  [Claudio Spizzi (@claudiospizzi)](https://github.com/claudiospizzi)

## [1.9.0.0] - 2017-11-15

- Added resource xDnsServerSetting
- MSFT_xDnsRecord: Added DnsServer property

## [1.8.0.0] - 2017-08-23

- Converted AppVeyor.yml to pull Pester from PSGallery instead of Chocolatey
- Fixed bug in xDnsServerADZone causing Get-TargetResource to fail with an
  extra property.

## [1.7.0.0] - 2016-05-18

- Unit tests updated to use standard unit test templates.
- MSFT_xDnsServerZoneTransfer
  - Added unit tests.
  - Updated to meet Style Guidelines.
- MSFT_xDnsARecord: Removed hard coding of Localhost computer name to
  eliminate PSSA rule violation.

## [1.6.0.0] - 2016-03-30

- Added Resource xDnsServerForwarder.
- Updated README.md with documentation and examples for xDnsServerForwarder
  resource.
- Added Resource xDnsServerADZone that sets an AD integrated DNS zone.
- Updated README.md with documentation and examples for xDnsServerADZone
  resource.
- Fixed bug in xDnsRecord causing Test-TargetResource to fail with multiple
  (round-robin) entries.
- Updated README.md with example DNS round-robin configuration.

## [1.5.0.0] - 2016-02-02

- Added Resource xDnsRecord with support for CNames.
  - This will replace xDnsARecord in a future release.
- Added **DnsServerPrimaryZone** resource

## [1.4.0.0] - 2015-12-02

- Added support for removing DNS A records

## [1.3.0.0] - 2015-10-22

- Fix to retrieving settings for record data

## [1.2.0.0] - 2015-09-11

- Removed UTF8 BOM from MOF schema

## [1.1.0.0] - 2015-05-01

- Add **xDnsARecord** resource.

## [1.0.0.0] - 2015-04-17

- Initial release with the following resources
  - **xDnsServerSecondaryZone**
  - **xDnsServerZoneTransfer**
