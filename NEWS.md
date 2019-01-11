# SmaRP 1.0.1-9000

* Retirement age automatically resets to 70 if a higher number is inserted (#27)
* Updated legal paramenters (#55)
* Removed unnecessary user_manual.Rmd vignette created with #60
* SmaRP version shown in the app and the report (#57)

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
