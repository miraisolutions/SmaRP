<img src="inst/application/www/SmaRPSticker.png" align="right" width="15%" height="15%"/>


# SmaRP: Smart Retirement Planning
SmaRP, Smart Retirement Planning has been designed and developed by [Mirai Solutions](https://mirai-solutions.ch/) to support people working in Switzerland in an educated decision-making process towards their retirement.

SmaRP is based on the Swiss Pension System and parametrized to reflect the complexity of its legal framework.


### Public version of the source code

This repo is a public version of the source code for SmaRP. The core functionalities are built in R. The application is based on the Shiny package and can be run locally or on a server.

If you got this far, we assume you can look after yourself with R and you already know how to install SmaRP.  

The core calculations are in  [SmaRP/R/core.R](https://github.com/miraisolutions/SmaRP/blob/master/R/core.R) and [SmaRP/R/TaxBenefits.R](https://github.com/miraisolutions/SmaRP/blob/master/R/TaxBenefit.R) whereas the app itself is contained in SmaRP/inst/application  and can be run from the root directory with

``` r 
shiny::runApp()
```

This code is completely open-sourced. While all care and diligence has been used, Mirai Solutions gives no warranty it is error free. Besides that, keep in mind that SmaRP is based on some assumptions and projections about the future (see bellow).  Therefore all figures reported in SmaRP should be understood as general references.

The app has been deployed under the following url using docker containers on the Google cloud. You can find all details in "SmaRP/inst/application"   

https://mirai-solutions.ch/apps/smarp/ 

Please use the [issue tracker on GitHub](https://github.com/miraisolutions/SmaRP/issues) to suggest enhancements or report problems.

For other questions and comments please use info@mirai-solutions.com.


### SmaRP key features

SmaRP projects the value at retirement of the occupational pension fund (known as Pillar II), the private pension fund (known as Pillar III) and also the tax relief arised from their contributions.

The *contributions to the Pillar II* are calculated from the salary plus additional voluntary purchases.

The *contributions to the Pillar III* are fully voluntary and repeated every year until retirement.

The tax savings is built as an additional fund where the contribution of certain year is the tax relief of the previous one. The tax relief is an approximation given your gross salary and some other personal details: Residence, civil status, number on kids, etc. 

The **results are presented in 3 different ways**. A *graph* displaying the projected funds over time until retirement, a *table* with the more detailed amounts and also a *downloadable report in PDF* where the user can find a more accurate and detailed explanation of the inputs and methodology implemented.     


### Detailed assumptions and limitations

- SmaRP uses [Continuous compounding interest](https://en.wikipedia.org/wiki/Compound_interest) in annual basis. 

- A constant interest rate during all working life are assumed.

- SmaRP does not take into account inflation, although there is a variable to project the average salary increase which can play as proxy.

- SmaRP applies only to employees, i.e. persons whose main income is a salary. Self-employed people are not considered.

- The state-run Pay-as-you-go system (Pillar I) is not considered.

- SmaRP assumes that  all tax benefits generated are 100% reinvested as an additional fund. The return of these tax benefits is assumed to be the same as those of the private pension fund.

- In case of married and double-income couples, the aggregated amount of all variables should be entered and a 50% income distribution is assumed.


### Data sources

SmaRP reflects the swiss pension system and therefore uses a many legal parameters and tables. You can find a nice summary here:

https://en.wikipedia.org/wiki/Pension_system_in_Switzerland

And more detailed explanation here:

https://www.bsv.admin.ch/bsv/de/home/sozialversicherungen/ueberblick.html

Within SmaRP, you can find those legal parameters with their concrete reference in [SmaRP/inst/application/global.R](https://github.com/miraisolutions/SmaRP/blob/master/inst/application/global.R). The tables are stored in  "SmaRP/inst/application/data"


### Testing

In a functional level, SmaRP has been tested as usual. ([See tests](https://github.com/miraisolutions/SmaRP/tree/master/tests/testthat)) 

At App level (integration test), SmaRP has been checked against some other free sources available on the web for Pillar II and Pillar III and tax calculators.

However, since the best test is always the real usage, we encorauge you to try it out and get back to us in case of inconsistencies or mistakes. Feedback will be highly appreciated. 




## Docker (to be removed and saved under xxxx???)

### Build Docker image (locally)

```
docker build -f Dockerfile -t mirai/smarp:latest .
```

### Push Docker image to the Google Container Registry

- Copy the `IMAGE ID` of the image you have just build:

```
docker images | head -n 2
```

- Tag your image by running the following Docker command:

```
docker tag <IMAGE-ID> eu.gcr.io/mirai-sbb/smarp:latest
```

- Then, push the image to Container Registry:

```
gcloud docker -- push eu.gcr.io/mirai-sbb/smarp:latest
```

### Pull Docker image from the Google Container Registry

To pull from the Google Container Registry, run the following command:

```
gcloud docker -- pull eu.gcr.io/mirai-sbb/smarp:latest
```

### Run Docker container (locally)

```
docker run -d -p 80:80 mirai/smarp
```

You can then load the SmaRP app in your browser:
http://localhost/

### Setting up a Google Kubernetes Engine (GKE) cluster

Create a new GKE cluster called "smarp":

```
gcloud container clusters create "smarp" --async --project "mirai-sbb" --zone "europe-west1-b" --cluster-version "1.9.7-gke.0" --machine-type "n1-standard-1" --image-type "COS" --disk-size "80" --scopes "default,storage-full,bigquery,datastore,sql,sql-admin" --num-nodes "1"
```

Get credentials for the newly created cluster:

```
gcloud container clusters get-credentials smarp
```

Run the latest version of the smarp Docker image in the GKE cluster:

```
kubectl run smarp --image=eu.gcr.io/mirai-sbb/smarp:latest
```

#### (Optional) Configuring a Load Balancer

Create `smarp-service` (i.e. a Load Balancer allowing you to connect to SmaRP
through a public IP address):

```
kubectl create -f smarp-service.yaml
```

Check the public IP address under which SmaRP is available:

```
kubectl describe service smarp-service | grep Ingress
```

### Continuous Integration / Continuous Delivery (CI/CD)

A build trigger has been configured to create a new Docker image and push it
to Google Container Registry every time a commit is pushed to the SmaRP `master`
branch on GitHub.

As part of the build (which at the moment takes about 6 minutes) a new container
is deployed to the GKE cluster and the old one gets deactivated.

You can check which builds have been triggered and the current status of a build
in the Google Cloud Console:
https://console.cloud.google.com/gcr/builds?project=mirai-sbb


## Google Cloud Setup for Conferences and Demos

For scenarios involving multiple concurrent users (for example during conferences or demos) it is recommended to use a Virtual Machine with higher specs (for example a `n1-standard-4`):

```
gcloud container clusters create "smarp" --async --project "mirai-sbb" --zone "europe-west1-b" --cluster-version "1.9.7-gke.0" --machine-type "n1-standard-4" --image-type "COS" --disk-size "80" --scopes "default,storage-full,bigquery,datastore,sql,sql-admin" --num-nodes "1"
```

Get credentials for the newly created cluster:

```
gcloud container clusters get-credentials smarp
```

Run the latest version of the smarp Docker image in the GKE cluster using explicit CPU and memory requests and limits:

```
kubectl run smarp --image=eu.gcr.io/mirai-sbb/smarp:latest --requests="cpu=3,memory=10Gi" --limits="cpu=3.5,memory=11Gi"
```

Configure a load balancer as described above. Then replace the existing IP address in

https://github.com/miraisolutions/miraisolutions.github.io/blob/master/apps/smarp/index.html#L9

with the new public IP address assigned to the load balancer.
