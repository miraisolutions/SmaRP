# SmaRP: Smart Retirement Planning
SmaRP, Smart Retirement Planning has been designed and developed by Mirai Solutions GmbH to support
users in an educated decision-making process towards their retirement.

SmaRP is structured as a package which contains a Shiny App

- Under \R we find the two main files which contain all the core functionalities: `core.r` and `TaxBenefit.r`. Contains also `launch_application.R` which triggers `runApp()`.

- In \inst\application are stored all files required to run the App

  - `server.r` and `ui.r` are the main files needed by a Shiny app.
  - `global.r` gathers all the official/legal information and provides them as input.
  - `helper_texts.r` collects all the text messages displayed on the info boxes.
  - `report.Rmd` and `swiss-case.Rmd` are the templates for the report.
  -  In \data are stored all information (tables) needed such the tax rates, the municipalities, etc.  

## Docker

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
