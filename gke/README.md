Deploy SmaRP on GKE with HTTP(S) load balancing
================

This document shows how to deploy the SmaRP Shiny app to GKE and set up
an HTTPS load balancer exposing it through a URL, usable for embedding
in website gallery.

## Initialization

Here we assume that a deployment `smarp` already exists for SmaRP,
running in the `smarp` cluster.

Check if the `smarp` cluster is the current context

``` bash
kubectl config current-context
## gke_mirai-sbb_europe-west1-b_smarp
```

You can set it otherwise by running

``` bash
gcloud container clusters get-credentials smarp
kubectl config current-context
## Fetching cluster endpoint and auth data.
## kubeconfig entry generated for smarp.
## gke_mirai-sbb_europe-west1-b_smarp
```

Query the available pods to check that `smarp` is deployed and running

``` bash
kubectl get pods -o wide
## NAME                    READY   STATUS    RESTARTS   AGE    IP         NODE                                   NOMINATED NODE   READINESS GATES
## smarp-57b6df7b6-hfmss   1/1     Running   24         7d1h   10.4.0.9   gke-smarp-default-pool-90e87a82-gdg4   <none>           <none>
```

## Setup and HTTP(s) load balancer

### References

  - [Concept: HTTP(s) load balancing with
    Ingress](https://cloud.google.com/kubernetes-engine/docs/concepts/ingress)
  - [Tutorial: Setting up HTTP Load Balancing with
    Ingress](https://cloud.google.com/kubernetes-engine/docs/tutorials/http-balancer)
  - [How-to: Configuring load balancing through
    Ingress](https://cloud.google.com/kubernetes-engine/docs/how-to/load-balance-ingress)
    (incl. multiple backend services)
  - [Tutorial: Configuring Domain Names with Static IP
    Addresses](https://cloud.google.com/kubernetes-engine/docs/tutorials/configuring-domain-name-static-ip)
  - [How-to: Configure SSL certificates for your Ingress load
    balancer](https://cloud.google.com/kubernetes-engine/docs/how-to/ingress-multi-ssl)

### Introduction

HTTP(S) load balancing in GKE is based on three major components

  - An optional **backend configuration**, which we need here in order
    to set a backend service [timeout higher than the
    default 30s](https://cloud.google.com/kubernetes-engine/docs/concepts/ingress#support_for_websocket).
    The timeout is
    [interpreted](https://cloud.google.com/load-balancing/docs/backend-service#backend_service_settings)
    as the maximum time the connection can live for [**WebSockets** on
    HTTP(S)](https://cloud.google.com/load-balancing/docs/https/#websocket_proxy_support),
    which is the case for Shiny.
  - A **NodePort** backend service to expose the deployment, using the
    backend configuration.
  - An
    [**Ingress**](https://cloud.google.com/kubernetes-engine/docs/concepts/ingress)
    associated with the NodePort backend service exposing the app,
    routing external HTTP(S) traffic to the applications via an external
    IP address. This also allows configuring TLS certificates for HTTPS
    connections through a custom sub-domain (see below).

### Backend configuration

We need to use a backend configuration to specify a sensible maximum
connection timeout, higher than the default 30s. Note that this is a
typical situation for WebSockets. A sensible value is 10800s (3h), since
it is also Kubernetes’ default [max session sticky
time](https://kubernetes.io/docs/concepts/services-networking/) for the
“ClientIP” `sessionAffinity`.

See [Configuring a backend service through
Ingress](https://cloud.google.com/kubernetes-engine/docs/how-to/configure-backend-service)
for more details. Note that the `BackendConfig` custom resource is in a
**Beta** release at the time of writing.

The corresponding `BackendConfig` YAML manifest, including session
affinity, is as follows

    ## # smarp-backendconfig.yaml
    ## apiVersion: cloud.google.com/v1beta1
    ## kind: BackendConfig
    ## metadata:
    ##   name: smarp-backendconfig
    ## spec:
    ##   timeoutSec: 10800 # 3h
    ##   sessionAffinity:
    ##     affinityType: "CLIENT_IP"

The BackendConfig is then created from the manifest as

``` bash
kubectl apply -f smarp-backendconfig.yaml
```

``` bash
kubectl get backendconfig smarp-backendconfig
## NAME                  AGE
## smarp-backendconfig   9d
```

### Expose your Deployment as a Service

The `NodePort` service manifest using the backend configuration created
above is as follows

    ## # smarp-backend.yaml
    ## apiVersion: v1
    ## kind: Service
    ## metadata:
    ##   labels:
    ##     run: smarp
    ##   name: smarp-backend
    ##   annotations:
    ##     beta.cloud.google.com/backend-config: '{"ports": {"80":"smarp-backendconfig"}}'
    ## spec:
    ##   type: NodePort
    ##   selector:
    ##     run: smarp
    ##   ports:
    ##   - port: 80
    ##     targetPort: 80

TCP `port` 80 of the created Service is associated with a BackendConfig
named `smarp-backendconfig` via annotation
`beta.cloud.google.com/backend-config`. A request sent to `port` 80 of
the service is forwarded to one of the member Pods on `targetPort` 80.
Note that each member Pod must have a container listening on the
specified `targetPort`. Note that there is no need to set the
[`cloud.google.com/app-protocols`](https://cloud.google.com/kubernetes-engine/docs/concepts/ingress#https_tls_between_load_balancer_and_your_application)
annotation to handle requests to port 443 for the HTTPS protocol, since
our app is not capable of receiving HTTPS requests.

An easy way to get the `labels` and `selector` right is to look at the
YAML generated for a standard `NodePort` service using
`expose`

``` bash
kubectl expose deployment smarp --target-port=80 --port=80 --type=NodePort --dry-run -o=yaml
```

The corresponding service is then created from the manifest as

``` bash
kubectl apply -f smarp-backend.yaml
```

``` bash
kubectl get service smarp-backend
## NAME            TYPE       CLUSTER-IP     EXTERNAL-IP   PORT(S)        AGE
## smarp-backend   NodePort   10.7.252.215   <none>        80:30816/TCP   9d
```

### Static IP address

  - [Tutorial: Configuring Domain Names with Static IP
    Addresses](https://cloud.google.com/kubernetes-engine/docs/tutorials/configuring-domain-name-static-ip)

  - [Reserving a Static External IP
    Address](https://cloud.google.com/compute/docs/ip-addresses/reserve-static-external-ip-address)

Create a static global IP address named `smarp-ip`

``` bash
gcloud compute addresses create smarp-ip --global
```

``` bash
gcloud compute addresses describe smarp-ip --global
```

### DNS record

In order to have a domain / sub-domain (e.g. `smarp.mirai-solutions.ch`)
pointing to the static `smarp-ip` address, domain name records must be
configured with the domain registrar, by adding an A (Address) type DNS
record for your domain or sub-domain name and have its value configured
with the reserved IP address.

Once this is done you should be able to visit the app by typing the
domain / sub-domain as URL (e.g. `https://smarp.mirai-solutions.ch`). It
might take several hours for the DNS records to propagate, you can check
it via

``` bash
host smarp.mirai-solutions.ch
## smarp.mirai-solutions.ch has address 35.186.252.175
```

### TLS certificate for HTTPS

Google Cloud Platform offers [Google-managed TLS
certificates](https://cloud.google.com/load-balancing/docs/ssl-certificates#managed-certs)
for (sub)-domains enabling HTTPS traffic. Certificates are automatically
provisioned and renewed and can be specified in an Ingress.

Note that the managed certificates are in a **Beta** release at the time
of writing.

See [How-to: Using Google-managed SSL
certificates](https://cloud.google.com/kubernetes-engine/docs/how-to/managed-certs).

#### Kubernetes cluster update

> Note: Managed certificates require clusters with masters running
> Kubernetes 1.12.6-gke.7 or higher.

You can check the `serverVersion` via

``` bash
kubectl version -o=yaml | grep -i version
```

If the version is below `1.12.6-gke.7`, You will have to manually
[upgrade the
cluster](https://cloud.google.com/kubernetes-engine/docs/how-to/upgrading-a-cluster)

To find the supported Kubernetes master and node versions for upgrades
and downgrades, run the following command:

``` bash
gcloud container get-server-config
```

You can manually upgrade the cluster’s master, and then the nodes can be
upgraded to the same version.

To upgrade the master’s version of the `smarp` cluster to a specific
version (that is not the default) run
e.g.

``` bash
gcloud container clusters upgrade smarp --master --cluster-version 1.12.6-gke.10
```

where `1.12.6-gke.10` is a new-enough version (typically the latest) you
found listed above. This can take 10-20 minutes.

Once you’ve upgraded your cluster’s master, the nodes can be upgraded to
the same version. The following command upgrades your nodes to the
version that your master is running:

``` bash
gcloud container clusters upgrade smarp
```

Wait for the operation to complete (a few minutes).

#### Google-managed certificate for the Ingress

You can define a ManagedCertificate resource for the
`smarp.mirai-solutions.ch` domain from above (pointing to `smarp-ip`)
using the YAML manifest

    ## # smarp-certificate.yaml
    ## apiVersion: networking.gke.io/v1beta1
    ## kind: ManagedCertificate
    ## metadata:
    ##   name: smarp-certificate
    ## spec:
    ##   domains:
    ##   - smarp.mirai-solutions.ch

and create the corresponding ManagedCertificate resource

``` bash
kubectl apply -f smarp-certificate.yaml
```

It is going to take between 10 minutes and up to 2 hours before the
certificate is provisioned and activated. While this occurs, you can
still proceed to creating the Ingress below, possibly `watch`ing the
`Certificate Status` via

``` bash
watch kubectl describe managedcertificate smarp-certificate
```

It will eventually switch from status `Provisioning` to status `Active`,
while the `Events` section will switch from `Create` to `<none>`.  
Note that the `Domain Status` can switch to `Status: FailedNotVisible`
along the way, especially if the **TTL** of your DNS record is low. This
doesn’t prevent the certificate from activating, however if the event
switches away from `Create` and you still see `Certificate Status:
Provisioning`, you may have to delete the certificate and check if
anything is wrong with your DNS configuration.

### Ingress configuration

Create the Ingress exposing the app via an external IP address,
associated with the TLS certificate defined above.

In the manifest, you can see that incoming requests are routed to port
80 of the `NodePort` service backend `smarp-backend`. Specify `smarp-ip`
in the Ingress manifest as `global-static-ip-name` annotation, and also
add `smarp-certificate` as `networking.gke.io/managed-certificates`

    ## # smarp-ingress.yaml
    ## apiVersion: extensions/v1beta1
    ## kind: Ingress
    ## metadata:
    ##   name: smarp-ingress
    ##   annotations:
    ##     kubernetes.io/ingress.global-static-ip-name: smarp-ip
    ##     networking.gke.io/managed-certificates: smarp-certificate
    ##     kubernetes.io/ingress.allow-http: "false"
    ## spec:
    ##   backend:
    ##     serviceName: smarp-backend
    ##     servicePort: 80

Then create the corresponding Ingress resource

``` bash
kubectl apply -f smarp-ingress.yaml
```

Wait a few minutes for the Ingress controller to configure an HTTP(S)
load balancer and an associated backend service. Be patient (8-12
minutes):

> Note: It may take a few minutes for GKE to allocate an external IP
> address and set up forwarding rules until the load balancer is ready
> to serve your application. In the meanwhile, you may get errors such
> as HTTP 404 or HTTP 500 until the load balancer configuration is
> propagated across the globe.

You can `watch` the status until you eventually see an IP address being
allocated to the Ingress

``` bash
watch kubectl get ingress smarp-ingress
```

You should be able to reach the app via HTTPS
<https://smarp.mirai-solutions.ch>, note that this can take longer and
require another 10-15 minutes until the certificate is active (see
above). You may want to keep watching it via

``` bash
watch -n 30 curl https://smarp.mirai-solutions.ch/
```

### Disable HTTP traffic

Note that we have disabled the HTTP traffic by including the annotation
`kubernetes.io/ingress.allow-http: "false"` in the YAML manifest.

Note that annotations can also be added or **removed dynamically**, e.g.

``` bash
kubectl annotate ingress smarp-ingress kubernetes.io/ingress.allow-http-
```

Notice the minus sign, `-`, at the end of the command.

## References

  - [Setting up HTTP Load Balancing with
    Ingress](https://cloud.google.com/kubernetes-engine/docs/tutorials/http-balancer)
  - [Configure SSL certificates for your Ingress load
    balancer](https://cloud.google.com/kubernetes-engine/docs/how-to/ingress-multi-ssl)
  - <https://cloud.google.com/kubernetes-engine/docs/how-to/load-balance-ingress>
  - <https://cloud.google.com/kubernetes-engine/docs/concepts/ingress#setting_up_https_tls_between_client_and_load_balancer>
  - <https://cloud.google.com/kubernetes-engine/docs/how-to/configure-backend-service>
  - <https://cloud.google.com/kubernetes-engine/docs/concepts/backendconfig>
      - <https://cloud.google.com/load-balancing/docs/enabling-connection-draining>
      - <https://cloud.google.com/compute/docs/reference/rest/v1/backendServices>

OBSOLETE

  - [Let’s Encrypt on
    GKE](https://github.com/ahmetb/gke-letsencrypt)
  - <https://blog.kubernauts.io/ingress-on-kubernetes-with-cert-manager-ad7d413d76f0a>
