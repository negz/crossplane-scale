# crossplane-scale

This repository contains Crossplane configuration used to test scalability of
the Crossplane control plane. At the time of writing it contains two Crossplane
configurations:

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

## Setup

Roughly:

1. Create a GKE cluster by applying `cluster.yaml`.
2. Deploy Crossplane v1.4.1 to said GKE cluster
3. Apply https://github.com/prometheus-operator/kube-prometheus/tree/release-0.9/manifests
4. Apply https://raw.githubusercontent.com/caicloud/event_exporter/master/deploy/deploy.yml
4. Apply `prom-pod-monitors.yaml`.

## Findings

An initial test of 100 `Bucket` claims (created using `./create-bucket.sh`)
shows that it took about 18 minutes for all claims to become ready. By contrast
a single `Bucket` claim becomes ready in about 30 seconds. Crossplane and the
RBAC manager appear to be well within their configured resource limits (and
provider-gcp has none):

```console
$ kubectl top pod --namespace crossplane-system --use-protocol-buffers
NAME                                                    CPU(cores)   MEMORY(bytes)   
crossplane-6f974db97-7wfwg                              64m          51Mi            
crossplane-provider-gcp-a5d5084d3e98-7c47d9f65b-8jx74   158m         108Mi           
crossplane-rbac-manager-dd8d65f77-8gbft                 4m           25Mi 
```

## Future Improvements

* Ideally the `xclusters` configuration would deploy a particular version of
  Crossplane to the GKE cluster, then install the `xbuckets` Configuration on
  said cluster. This is currently blocked by [crossplane-runtime#281][281].

[storage-quotas]: https://cloud.google.com/storage/quotas
[operations-pricing]: https://cloud.google.com/storage/pricing#operations-pricing
[281]: https://github.com/crossplane/crossplane-runtime/issues/281