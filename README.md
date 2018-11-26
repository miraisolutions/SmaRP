<img src="inst/application/www/SmaRPSticker.png" align="right" width="15%" height="15%"/>


# SmaRP: Smart Retirement Planning
Smart Retirement Planning (SmaRP) is a [Mirai Solutions](https://mirai-solutions.ch/) initiative designed to guide people working in Switzerland towards a strategic decision-making process for their retirement.

SmaRP is based on the Swiss Pension System and parameterized to reflect the complexity of its legal framework.


### Public version of the source code

This report qualitatively describes the source code for SmaRP, whose functionalities are built in R. The application is based on the Shiny package and can be run locally or on a server.

If you got this far, we assume that you are familiar with the basics of R and can independently install a shiny app. 

The project is completely open-sourced. Core calculations are in [SmaRP/R/core.R](https://github.com/miraisolutions/SmaRP/blob/master/R/core.R) and [SmaRP/R/TaxBenefits.R](https://github.com/miraisolutions/SmaRP/blob/master/R/TaxBenefit.R) whereas UI scripts can be found in [SmaRP/inst/application](https://github.com/miraisolutions/SmaRP/blob/master/inst/application). To open the app, it is sufficient to type the following code in the root directory:

``` r 
shiny::runApp()
```

The app has been deployed using [docker containers](https://www.docker.com/resources/what-container) on Google cloud and can viewed by clicking on the following URL:

https://mirai-solutions.ch/apps/smarp/ 


While our developers worked under the outmost care and diligence, Mirai Solutions does not guarantee that it is error free. In addition, please keep in mind that SmaRP is based on some assumptions and projections (explained in the third section of this document) and thus all figures reported in SmaRP should be understood as general references.


### SmaRP key features

SmaRP projects the value of the occupational pension fund (Pillar II), the private pension fund (Pillar III) and the tax relief derived from their contributions at the desired retirement age.

*Contributions to Pillar II* are calculated from the salary and any additional voluntary purchases.

*Contributions to Pillar III* are fully voluntary and repeated every year until retirement.

*Tax savings* are built as an additional fund where tax relives from a certain year are used as contributions for the next. Tax relieves are calculated using an approximation of the given gross salary and other factors including: residence, civil status, number on kids, etc. 

**Results are displayed in 3 different ways**:

1. a graph showing the projected funds over time until retirement
2. a table with the more detailed amounts 
3. a downloadable report in PDF where the user can find a more accurate and detailed explanation of the inputs and methodology implemented. 

### Assumptions and limitations

- [Continuous compounding interest](https://en.wikipedia.org/wiki/Compound_interest) is annually based. 

- Constant interest rates are present throughout the working life.

- Inflation is not taken into account, although a variable exists to project the average salary increase which can play as proxy.

- This plan is valid only for employees, i.e. persons whose main income is a salary. Self-employed people do not belong to this category.

- The state-run Pay-as-you-go system (Pillar I) is not considered.

- SmaRP assumes that  all tax benefits generated are 100% reinvested as an additional fund. The return of these tax benefits is assumed to be the same as those of the private pension fund.

- In case of married and double-income couples, the aggregated amount of all variables should be entered and a 50% income distribution is assumed.


### Data sources

SmaRP reflects the Swiss pension system and therefore uses legal parameters and tables. You can find an overview of these components here:

https://en.wikipedia.org/wiki/Pension_system_in_Switzerland

And a more detailed explanation here:

https://www.bsv.admin.ch/bsv/de/home/sozialversicherungen/ueberblick.html

Within SmaR legal parameters are stored in [SmaRP/inst/application/global.R](https://github.com/miraisolutions/SmaRP/blob/master/inst/application/global.R) and tables in  [SmaRP/inst/application/data](https://github.com/miraisolutions/SmaRP/blob/master/inst/application/data).


### Testing

On a functional level, SmaRP has undergone standard tests. [See tests](https://github.com/miraisolutions/SmaRP/tree/master/tests/testthat)

On an app level (integration test), SmaRP has been checked against other online free sources for Pillar II and III and tax calculators.

However, since the best test is always the real usage, we encourage you to try it out and get back to us! Feedback is always highly appreciated. Please use the issue tracker on GitHub to suggest enhancements or report problems and send us an email at info@mirai-solutions.com for any questions and comments.
