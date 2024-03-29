
<img src="inst/application/www/SmaRPSticker.png" align="right" width="15%" height="15%"/>

# SmaRP: Smart Retirement Planning

Smart Retirement Planning (**SmaRP**) is a [Mirai Solutions](https://mirai-solutions.ch/) initiative designed to guide people working in Switzerland towards a strategic decision-making process for their retirement.

**SmaRP** is based on the [Swiss pension system](https://en.wikipedia.org/wiki/Pension_system_in_Switzerland) and reflects the complexity of its legal framework.
It is implemented as an [R Shiny](https://shiny.rstudio.com/) pension calculator web app, in the form of an R package.
The app features a flexible yet intuitive user interface with detailed personalization parameters and options.
This allows to interactively compute and display the evolution of the retirement funds over time, split into their contributing components.
A report including details regarding calculation methodology and approximations can be generated and downloaded.

Thanks to the open-source nature of the project, the underlying assumptions and calculations are fully disclosed.
Unlike other pension calculators, this makes results transparent, comparable, and reproducible.


## Using SmaRP

The **SmaRP** Shiny app is [deployed](gke#readme) to Google Cloud Platform
(using [Docker containers](https://www.docker.com/resources/what-container)) and
can be accessed at https://mirai-solutions.ch/gallery/smarp.

**SmaRP** is developed using a [GitFlow](git-flow#readme) approach, where the `master` branch always reflects the _latest_ [release](https://github.com/miraisolutions/SmaRP/releases) of the live app, whereas branch `develop` collects the latest delivered developments for the _next_ releases.

The R package **SmaRP** for the latest release can be installed from GitHub with
<!-- argument build_vignettes not available anymore (r-lib/remotes#353), build_opts = "" for a full installation including vignettes  -->
``` r
remotes::install_github("miraisolutions/SmaRP@master", build_opts = "")
```
whereas the development version can be installed via
``` r
remotes::install_github("miraisolutions/SmaRP@develop", build_opts = "")
```

Then, the installed package can be used to serve the app locally from R via
``` r
SmaRP::launch_application()
```

Note that **SmaRP** is deployed using [version-stable](https://github.com/rocker-org/rocker-versioned#readme) images from the [Rocker project](https://www.rocker-project.org/). The target environment of the live app is currently bound to R 3.5.3. Therefore, the app is developed and tested with the corresponding version of R and packages, as opposed to the latest available versions. This is made easy by the containerized approach to align version-stable development and deployment environments described in our [techguides](https://mirai-solutions.ch/techguides/align-local-development-and-deployment-environments.html).


## Details and key features

The evolution of the total retirement fund over time is computed by projecting the value of the occupational fund (2nd Pillar), the private fund (3rd Pillar) and the tax relief, thus deriving their contributions at the desired retirement age.

- _Contributions to the second Pillar_ are calculated from the salary and any additional voluntary purchases.

- _Contributions to the third Pillar_ are fully voluntary and repeated every year until retirement.

- _Tax savings_ are built as an additional fund where tax relieves from a certain year are used as contributions for the next. Tax relieves are calculated using an approximation of the given gross salary and other factors including: residence, civil status, number on kids, etc. 

**Results** of the calculation are available in **SmaRP** in 3 different ways:

1. a **graph** showing the projected funds over time until retirement
2. a **table** with details about projected quantities (also available for download)
3. a downloadable **PDF report** including detailed explanations of the calculation methodology and inputs.


### Assumptions and limitations

- Projected funds are computed using [continuously compounded returns](https://en.wikipedia.org/wiki/Compound_interest#Continuous_compounding) on annual basis.
- Constant interest rates are assumed throughout the working life.
- Inflation is not taken into account, although it can be proxied using the salary growth rate input.
- The retirement plan is valid for employees only, i.e. persons whose main income is a salary. Self-employed people do not belong to this category.
- The publicly managed pay-as-you-go system (1st Pillar) is not considered.
- All generated tax benefits are 100% reinvested as an additional fund, interpreting the same return as the private fund.
- In case of married couples with double income, the combined amount of all variables should be entered and a 50% income distribution is assumed.


### Source code

Core calculations behind this Shiny app have been implemented via several functions, collected in the main source files [SmaRP/R/core.R](R/core.R) and [SmaRP/R/TaxBenefits.R](R/TaxBenefit.R).

Documentation for the relevant exported functions used in the app is also provided and can be browsed via
``` r
help(package = "SmaRP")
```
On a functional level, the code is covered by extensive [unit tests](tests/testthat).


The source code for the app itself is available under  [SmaRP/inst/application](inst/application).


### Data sources and references

**SmaRP** reflects the Swiss pension system and uses corresponding legal parameters and data.
An overview of these components can be found at e.g. https://en.wikipedia.org/wiki/Pension_system_in_Switzerland.
A more detailed explanation is available on the Swiss [Federal Social Insurance Office](https://www.bsv.admin.ch/bsv/de/home/sozialversicherungen/ueberblick.html) website (in German).


Legal parameters in **SmaRP** are defined in [SmaRP/inst/application/global.R](inst/application/global.R), whereas data is stored under [SmaRP/inst/application/data](inst/application/data).


### Accuracy

While **SmaRP** was developed under the utmost care and diligence, Mirai Solutions does not guarantee for its accuracy and correctness. In addition, **SmaRP** is based on assumptions and projections (explained in a section above and in the PDF report) and as such computed figures should be understood as general references and do not hold any legal value.

Besides standard unit tests at the functional level, results from the **SmaRP** web app have been checked against other online free sources for second, third Pillars and tax calculators.

To keep testing and improving **SmaRP**, we encourage users to get back to us! Your feedback is always highly appreciated. You can use the issue tracker on GitHub to suggest enhancements or report problems, and reach out via email at info@mirai-solutions.com for any questions and comments.
