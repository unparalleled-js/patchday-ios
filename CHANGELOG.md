# Changelog

## 3.0.2

### Fixed

- Issue where the Pill tab would not display badge alerts when notifications were disabled for the Pill.
- Issue where the App badge would not update when changing a due Pill right away.
- Issue where new Pills did not default to Notify=true like they did before.

## 3.0.1

### Fixed

- Issue where the Unsaved Changes Alert did not block the navigation after editing a hormone and tapping Back.
- Issue where if you declined adding a new site name from a type-edit on a hormone, it would not set the site.

## 3.0.0

### Added

- Dark mode.
- Estro-Gel hormonal delivery method support with site choices:
	- Arms
	Supports custom sites.
- The concept of "Pill Schedules" with choices:
	- Every Day (previously was only one supported)
	- Every Other Day
	- First 10 Days of the Month
	- First 20 Days of the Month
	- Last 10 Days of the Month
	- Last 20 Days of the Month
	Available by editing a pill in the Pill Schedule.
- Hormone Cell Actions, useful for quickly changing Hormones.
- Warning for when leaving views without saving changes.
	- Leaving Hormone Details View.
	- Leaving Pill Details View.
- Icon improvements.
- Increased sizes.
	- Changed Site Schedule tab icon.
- A Moon icon now displays in the top right of a Hormone Cell for overnight Hormones.

### Changed

- Taking Pills is handled through alert actions now. Simply select the PillCell to Take a pill.
- Editing Pills is handled through alert actions now. Simply select the PillCell to Edit pill details.
- The SiteSchedule no longer cares about occupied sites and just follows the site Index accordingly.

### Fixed

- Bug with custom sites not being scheduled correctly.