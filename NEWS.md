# SmaRP 1.0.1-9000

* Retirement age automatically resets to 70 if a higher number is inserted (#27)
* App does not crash when number of children or desired retirement age do not have an input value (#28)
* Updated legal parameters (01.01.2019) (#55)
* SmaRP version shown in the app and the report (#57)
* Added user_manual vignette (#65)
* Removed unnecessary user_manual.Rmd vignette created with (#60)
* Added sentence about not storing information in disclaimer, created "Download Data" button when table is displayed (#67)
* Updated taxes tests after updating tax parameters for 2017 (#68)
* Support responsive embedding via iframe-resizer (#69)
* Retirement age changes depending on the selected genre (#72)
* Made "c" in "calendar" capital, added tooltip to "Generate Report" button, made "Disclaimer" bold, rephrased first sentence, and removed second (#77)
* Changed "genre" to "gender" (#79)
* In report: changed multiplication symbol * to \cdot, reviewed disclaimer, fixed typos, church types translated to English, fixed tables columns names (no underscore, leave space between words), date of birth in Parameters section changed in the form: dd-mm-yyyy (#82)
* Fixed numeric input so that it doesn't crash when no value is inserted (#81)
* Report footer restructured (#53)
* Dynamic plot size and improved labels (no underscore, space between words) in the Shiny app (#85)
* Report review and updates (#89)

# SmaRP 1.0.1

## Patch release

* Report spell check (#49)
* Retirement age automatically resets to 70 if a higher number is inserted (#27)
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
