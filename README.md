<!--# The Swiss social security system, considered as one of the most robust, is based on a three-pillar regime.
# The first Pillar, common to most developed countries, is a state-run pay-as-you-earn system with minimum benefits.
# The voluntary contribution (Pillar III) is a privately-run, tax-deductible insurance fund.
# At the heart of the Swiss system is the so-called Pillar II, a compulsory, tax-deductible company occupational pension insurance fund.
# Voluntary additional Pillar II buy-ins are regulated but allow for benefits improvement at retirement age while reducing the tax burden during the working career.
# The complexity is further increased by a municipality-dependent taxation.
# Altogether this calls for an early-stage conscious approach towards retirement planning.
# However, it is not straight-forward to assess effects of elements such as early retirement, moving to a different canton or applying a different voluntary pension schema.
# SmaRP, Smart Retirement Planning, supports the users in an educated decision-making process.
-->

<img src="inst/application/www/SmaRPSticker.png" align="right" width="15%" height="15%"/>

# SmaRP: Smart Retirement Planning

Smart Retirement Planning (**SmaRP**) is a [Mirai Solutions](https://mirai-solutions.ch/) initiative designed to guide people working in Switzerland towards a strategic decision-making process for their retirement.

**SmaRP** is based on the [Swiss pension system](https://en.wikipedia.org/wiki/Pension_system_in_Switzerland) and reflects the complexity of its legal framework.
It is implemented as an [R Shiny](https://shiny.rstudio.com/) pension calculator web app, in the form of an R package.
The app features a flexible yet intuitive user interface with detailed personalization parameters and options.
This allows to interactively compute and display the evolution of the retirement funds over time, split into its contributing components.
A downloadable report including details regarding calculation methodology and approximations can also be produced.

Thanks to the open-source nature of the project, the underlying assumptions and calculations are fully disclosed.
Unlike other pension calculators, this makes results transparent, comparable, and reproducible.


## Using SmaRP

The **SmaRP** Shiny app is deployed to Google Cloud Platform (using [docker
containers](https://www.docker.com/resources/what-container)) and can be
accessed at https://mirai-solutions.ch/apps/smarp/.

The (development version of) **SmaRP** can also be served locally by installing the package from GitHub
``` r
devtools::install_github("miraisolutions/SmaRP", build_vignettes = TRUE)
```
and running
``` r
SmaRP::launch_application()
```


## Details and key features

The evolution of the total retirement fund over time is computed by projecting the value of the occupational pension fund (Pillar II), the private pension fund (Pillar III) and the tax relief, thus deriving their contributions at the desired retirement age.

*Contributions to Pillar II* are calculated from the salary and any additional voluntary purchases.

*Contributions to Pillar III* are fully voluntary and repeated every year until retirement.

*Tax savings* are built as an additional fund where tax relieves from a certain year are used as contributions for the next. Tax relieves are calculated using an approximation of the given gross salary and other factors including: residence, civil status, number on kids, etc. 

**Results** of the calculation are available in **SmaRP** in 3 different ways:

1. a **graph** showing the projected funds over time until retirement
2. a **table** with details about projected quantities (also available for download)
3. a downloadable **PDF report** including detailed explanations of the calculation methodology and inputs.


### Assumptions and limitations

- Projected funds are computed using [continuously compounded returns](https://en.wikipedia.org/wiki/Compound_interest#Continuous_compounding) on annual basis.
- Constant interest rates are assumed throughout the working life.
- Inflation is not taken into account, although it can be proxied using the salary growth rate input.
- The retirement plan is valid for employees only, i.e. persons whose main income is a salary. Self-employed people do not belong to this category.
- The publicly managed pay-as-you-go system (Pillar I) is not considered.
- All generated tax benefits are 100% reinvested as an additional fund, interpreting the same return as the private pension fund.
- In case of married couples with double income, the combined amount of all variables should be entered and a 50% income distribution is assumed.


### Source code

Core calculations behind this Shiny app have been implemented via several functions, collected in the main source files [SmaRP/R/core.R](https://github.com/miraisolutions/SmaRP/blob/master/R/core.R) and [SmaRP/R/TaxBenefits.R](https://github.com/miraisolutions/SmaRP/blob/master/R/TaxBenefit.R).

Documentation for the relevant exported functions used in the app is also provided and can be browsed via
``` r
help(package = "SmaRP")
```
On a functional level, the code is covered by extensive [unit tests](https://github.com/miraisolutions/SmaRP/tree/master/tests/testthat).


The source code for the app itself is available under  [SmaRP/inst/application](https://github.com/miraisolutions/SmaRP/blob/master/inst/application).


### Data sources and references

**SmaRP** reflects the Swiss pension system and uses corresponding legal parameters and data.
An overview of these components can be found at e.g. https://en.wikipedia.org/wiki/Pension_system_in_Switzerland.
A more detailed explanation is available on the Swiss [Federal Social Insurance Office](https://www.bsv.admin.ch/bsv/de/home/sozialversicherungen/ueberblick.html) website (in German).


Legal parameters in **SmaRP** are defined in [SmaRP/inst/application/global.R](https://github.com/miraisolutions/SmaRP/blob/master/inst/application/global.R), whereas data is stored under  [SmaRP/inst/application/data](https://github.com/miraisolutions/SmaRP/blob/master/inst/application/data).


### Accuracy

While **SmaRP** was developed under the utmost care and diligence, Mirai Solutions does not guarantee for its accuracy and correctness. In addition, **SmaRP** is based on assumptions and projections (explained in a section above and in the PDF report) and as such computed figures should be understood as general references and do not hold any legal value.

Besides standard unit tests at the functional level, results from the **SmaRP** web app have been checked against other online free sources for Pillar II and III and tax calculators.

To keep testing and improving **SmaRP**, we encourage users to get back to us! Your feedback is always highly appreciated. You can use the issue tracker on GitHub to suggest enhancements or report problems, and reach out via email at info@mirai-solutions.com for any questions and comments.

### Branches
