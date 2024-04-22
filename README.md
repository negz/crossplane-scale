# crossplane-scale

This repository contains configurations and scripts used to test the scalability
of Crossplane. It's mostly for my own future reference.

## Controller Scalability

These tests use two Crossplane configurations:

* `xclusters.test.crossplane.io` deploys the control plane that will be tested.
* `xbuckets.test.crossplane.io` is deployed many times to the control plane.

The idea is to create a Kubernetes cluster broadly representative of somewhere
Crossplane might be deployed in production, then to create many instances of a
Crossplane Composite Resource (XR) that again might be broadly representative of
a real, production XR. The `xbuckets` configuration defines an XR that attempts
to exercise many of Crossplane's features. Specifically it:

* Offers a claim.
* Exposes a connection secret.
* Composes a realistic number of managed resources.
* Patches both to and from the composite resource.

The test uses GCP and GCS buckets, which _appear_ to be a good candidate for
scale testing. Buckets can be spun up and down fairly quickly, and do not appear
to be subject to any quota limits - i.e. there is no documented maximum number
of allowed buckets per project. Instead bucket creation and deletion is [rate
limited][storage-quotas] to approximately one CRUD operation every two seconds.
GCS does [bill per operation][operations-pricing], so running scale tests is not
free. The cost appears to be minimal though, at $0.05 per 10,000 creates (aka
'inserts'), and $0.004 per 10,000 observes (aka 'gets'). IAM service accounts
are also used in the scale testing composition. There are no documented costs
for number of service accounts, but they are limited to 100 per project. It's
possible to request a quota increase via the GCP console, and we've had the
quota used for our testing project increased to 1,200.

Roughly:

1. Create a GKE cluster by applying
  a. `package/xclusters.test.crossplane.io/composition-gcp.yaml`
  b. `package/xclusters.test.crossplane.io/definition.yaml`
  c. `cluster-gcp.yaml`.
2. Deploy Crossplane to said GKE cluster (e.g. `up uxp install --set metrics.enabled=true`).
3. Apply https://github.com/prometheus-operator/kube-prometheus/tree/release-0.9/manifests
4. Apply https://raw.githubusercontent.com/caicloud/event_exporter/master/deploy/deploy.yml
5. Apply `prom-pod-monitors.yaml`.

## CRD Scalability

These tests (optionally) use the same configurations as above to spin up a
Kubernetes cluster to test. The rest is down to filling the API Server up with
CRDs. You can do this one of two ways:

```console
# Install Crossplane and use the package manager

# Install the up CLI. See https://github.com/upbound/up.
curl -sL https://cli.upbound.io | sh

# Install Crossplane. We need 1.9.0-up.3 or above.
# See https://github.com/upbound/universal-crossplane
up uxp install 1.9.0-up.3 --set metrics.enabled=true

# You'll want kubectl v1.25.0 or above to avoid slowness due to too many CRDs
# per https://blog.upbound.io/scaling-kubernetes-to-thousands-of-crds/
kubectl apply -f full-coverage-providers.yaml
```

or...

```console
# Directly apply ~1,800 Crossplane CRDs.
kubectl apply -f etoomanycrds/latest-crds 
```

[storage-quotas]: https://cloud.google.com/storage/quotas
[operations-pricing]: https://cloud.google.com/storage/pricing#operations-pricing