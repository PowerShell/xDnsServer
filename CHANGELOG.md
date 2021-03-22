# Change log for xDnsServer

The format is based on and uses the types of changes according to [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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
    PowerShell module ([issue #37](https://github.com/dsccommunity/xDnsServer/issues/37)).
  - Added the base class `ResourcePropertiesBase` to hold DSC properties that should be
    inherited for all class-based resources.
- xDNSServerClientSubnet
  - Added integration tests.
- xDnsServerPrimaryZone
  - Added integration tests ([issue #173](https://github.com/dsccommunity/xDnsServer/issues/173)).
  - Added more examples.
- xDnsRecordMx
  - Added new resource to manage MX records
- xDnsServerZoneScope
  - Added integration tests ([issue #177](https://github.com/dsccommunity/xDnsServer/issues/177)).
  - New read-only property `ZoneFile` was added to return the zone scope
    file name used for the zone scope.
- xDnsServerZoneAging
  - Added integration tests ([issue #176](https://github.com/dsccommunity/xDnsServer/issues/176)).
- xDnsServerForwarder
  - Added integration tests ([issue #170](https://github.com/dsccommunity/xDnsServer/issues/170)).
- xDnsServerRootHint
  - Added integration tests ([issue #174](https://github.com/dsccommunity/xDnsServer/issues/174)).
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
- DnsRecordCname
  - Added new resource to manage CNAME records
- DnsRecordCnameScoped
  - Added new resource to manage scoped CNAME records

### Changed

- xDnsServer
  - BREAKING CHANGE: Set the minimum required PowerShell version to 5.0 to support classes used in the DnsRecordBase-derived resources.
  - Resolve style guideline violations for hashtables
  - Update pipeline files.
  - Renamed the default branch to `main` ([issue #131](https://github.com/dsccommunity/xDnsServer/issues/131)).
  - Uses `PublishPipelineArtifact` in  _Azure Pipelines_ pipeline.
  - Unit tests are now run in PowerShell 7 in the _Azure Pipelines_
    pipeline ([issue #160](https://github.com/dsccommunity/xDnsServer/issues/160)).
  - Merged the historic changelog into CHANGELOG.md ([issue #163](https://github.com/dsccommunity/xDnsServer/issues/163)).
  - Only add required role in integration tests pipeline.
  - Updated the pipeline to use new deploy tasks.
  - Revert back to using the latest version of module Sampler for the pipeline ([issue #211](https://github.com/dsccommunity/xDnsServer/issues/211)).
- xDnsRecordSrv
  - Now uses `[CimInstance]::new()` both in the resource code and the resource
    unit test to clone the existing DNS record instead of using the method
    `Clone()` that does not exist in PowerShell 7.
- xDnsServerSetting
  - BREAKING CHANGE: The mandatory parameter was replaced by the mandatory
    parameter `DnsServer`. This prevents the resource from being used twice
    in the same configuration using the same value for the parameter `DnsServer`
    ([issue #156](https://github.com/dsccommunity/xDnsServer/issues/156)).
- xDnsServerDiagnostics
  - BREAKING CHANGE: The mandatory parameter was replaced by the mandatory
    parameter `DnsServer`. This prevents the resource from being used twice
    in the same configuration using the same value for the parameter `DnsServer`
    ([issue #157](https://github.com/dsccommunity/xDnsServer/issues/157)).
- xDnsServerPrimaryZone
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
    module _DscResource.Common_ ([issue #166](https://github.com/dsccommunity/xDnsServer/issues/166)).
  - Remove helper function `ConvertTo-CimInstance` in favor of the one in
    module _DscResource.Common_ ([issue #167](https://github.com/dsccommunity/xDnsServer/issues/167)).
  - Remove helper function `ConvertTo-HashTable` in favor of the one in
    module _DscResource.Common_ ([issue #168](https://github.com/dsccommunity/xDnsServer/issues/168)).
- xDnServerSetting
  - BREAKING CHANGE: The properties `LogIPFilterList`, `LogFilePath`, `LogFileMaxSize`,
    and `EventLogLevel` have been removed. Use the resource _xDnsServerDiagnostics_
    with the properties `FilterIPAddressList`, `LogFilePath`, `MaxMBFileSize`,
    and `EventLogLevel` respectively to enforce these settings ([issue #190](https://github.com/dsccommunity/xDnsServer/issues/190)).
    This is done in preparation to support more settings through the cmdlet
    `Get-DnsServerSetting` for the resource _xDnServerSetting_, and these
    values are not available through that cmdlet.

### Fixed

- xDnsServer
  - Enable Unit Tests to be run locally.
  - Rename integration tests so they are run in the pipeline ([issue #134](https://github.com/dsccommunity/xDnsServer/issues/134)).
  - Added back the build task to create releases on GitHub.
  - Fixed property descriptions in schema throughout.
  - Fixed uploading of code coverage that was broken since Sampler had a bug.
  - Fixed examples so the license information point to the correct default branch.
  - Fixed a link in the README.md.
- DnsRecordBase
  - Fixed so that `Compare-DscParameterState` is used in the method `Test()`
    if the record already exist, to compare the properties except `Ensure`
    in the desired state against the actual state ([issue #205](https://github.com/dsccommunity/xDnsServer/issues/205)).
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
    ([issue 79](https://github.com/PowerShell/xDnsServer/issues/79)).
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
    `ReplicationScope` is not `Custom`. ([issue #110](https://github.com/dsccommunity/xDnsServer/issues/110)).
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
- Changes to xDnsServerPrimaryZone
  - Fix bug in Get-TargetResource that caused the Zone Name to be null
    ([issue #63](https://github.com/dsccommunity/xDnsServer/issues/63)).
    [Brandon Padgett (@gerane)](https://github.com/gerane)
- Changes to xDnsRecord
  - Added Ptr record support (partly resolves issue #34).
    [Reggie Gibson (@regedit32)](https://github.com/regedit32)

## [1.10.0.0] - 2018-05-02

- Changes to xDnsServerADZone
  - Fixed bug introduced by [PR #49](https://github.com/dsccommunity/xDnsServer/pull/49).
    Previously, CimSessions were always used regardless of connecting to a
    remote machine or the local machine.  Now CimSessions are only utilized
    when a computername, or computername and credential are used ([issue #53](https://github.com/dsccommunity/xDnsServer/issues/53)).
  [Michael Fyffe (@TraGicCode)](https://github.com/TraGicCode)
- Fixed all PSSA rule warnings. [Michael Fyffe (@TraGicCode)](https://github.com/TraGicCode)
- Fix DsAvailable key missing ([#66](https://github.com/dsccommunity/xDnsServer/issues/66)).
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
- Added **xDnsServerPrimaryZone** resource

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
