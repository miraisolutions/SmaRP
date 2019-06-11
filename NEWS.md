# SmaRP 1.1.1-9000

* launch_application() exposes the launch.browser argument to shiny::runApp (#108).
* Updated install_github() README instructions due to un-supported build_vignettes argument (#120).
* Automatic cleanup of data created via configure (#119).
* Background header does not re-center with increasing page width (#123).
* DESCRIPTION file includes URL and BugReports sections (#125).
* Made a few syntax changes in vignettes (#101).
* Changed Pillars nomenclature to be consistent with official terminology (#103).
* Annual Contribution initialized at 5000, numericInput re-set to 0 or minimum 
value if lower number is inserted, unused maximum values erased (#129).


# SmaRP 1.1.1

### Fixes

* Bar-plot missing in the PDF report (#96).
* PDF report refers to wrong pillars (#105).
* Checkboxes and radio buttons don't render properly in Safari browser (#102).

### Maintenance

* Aligned plot labels with table headers in the report.
* Removed obsolete dependency on package webshot and PhantomJS (#97).

# SmaRP 1.1.0

* Retirement age automatically resets to 70 if a higher number is inserted (#27)
* Retirement age changes depending on the selected genre (#72)
* Updated legal parameters (01.01.2019) and tests (#55, #68)
* Removed user_manual.Rmd vignette created with (#60) and added new one (#65)
* SmaRP version shown in the app and the report (#57)
* Report review and updates (#82, #53, #89)
* Added sentence about not storing information in disclaimer, created "Download Data" button when table is displayed (#67)
* Made "c" in "calendar" capital, added tooltip to "Generate Report" button, made "Disclaimer" bold, rephrased first sentence and removed second (#77)
* "genre" changed to "gender" (#79)
* Fixed numeric input so that it doesn't crash when no value is inserted (#81, #28)
* Support responsive embedding via iframe-resizer (#69)
* Dynamic plot size and improved labels (no underscore, space between words) in the Shiny app (#85)

# SmaRP 1.0.1

## Patch release

* Report spell check (#49)
* Documentation reviewed (#59)
* Fixed tooltip automatic disappearing (#54)

# SmaRP 1.0.0

## First versioned release of SmaRP

Smart Retirement Planning **SmaRP** is a [Mirai Solutions](https://mirai-solutions.ch/) tool allowing people working in Switzerland to explore parameters and monetary measures related to retirement and pension.

**SmaRP** is based on the [Swiss pension system](https://en.wikipedia.org/wiki/Pension_system_in_Switzerland) and reflects the complexity of its legal framework.
It is implemented as an [R Shiny](https://shiny.rstudio.com/) pension calculator web app, in the form of an R package.
The app features a flexible yet intuitive user interface with detailed personalization parameters and options.
This allows to interactively compute and display the evolution of the retirement funds over time, split into their contributing components.
A report including details regarding calculation methodology and approximations can be generated and downloaded.

Thanks to the open-source nature of the project, the underlying assumptions and calculations are fully disclosed.
Unlike other pension calculators, this makes results transparent, comparable, and reproducible.
