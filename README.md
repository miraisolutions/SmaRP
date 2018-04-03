# SmaRP: Smart Retirement Planning
Shiny app for projecting retirement funds/benefits.

The app is structured as follow:

- `server.r` and `ui.r` are the main files needed by a Shiny app
- `core.r` contains all the functions needed to perform the calculations
- `input_sources.r` gathers all the official/legal information and provides them as input
- `report.Rmd` is the template formatted report

## Docker

### Build Docker image

```
docker build -f Dockerfile -t mirai/smarp:latest .
```

### Push Docker image to the Google Container Registry

- Tag your image by running the following Docker command:

```
docker tag <image-id> eu.gcr.io/mirai-sbb/smarp:latest
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
docker run -d -p 3838:3838 mirai/smarp
```

You can then load the SmaRP app in your browser:
http://localhost:3838/
