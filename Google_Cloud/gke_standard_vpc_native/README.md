# GKE VPC-native cluster

Note: when destroying the resources, there are some additional resources attached to the custom VPC--created by GCP--that must be deleted manually first (e.g. default route & NEG for the custom VPC)

```bash
gcloud compute routes list

gcloud compute network-endpoint-groups list
```