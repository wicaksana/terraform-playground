# EKS - simple cluster

* Single NAT gateway: only use one NAT gateway for all public subnets.
* Public subnet tag --> `kubernetes.io/role/elb`=1: public subnet must be tagged with that value so that Kubernetes knows to use only those subnets for external load balancers instead of choosing a public subnet in each Availability Zone ([reference](https://docs.aws.amazon.com/eks/latest/userguide/network-load-balancing.html#_prerequisites)).
* Private subnet tag --> `kubernetes.io/role/internal-elb` = 1: [reference](https://docs.aws.amazon.com/eks/latest/userguide/network-load-balancing.html#_prerequisites)
* Amazon EKS add-ons: https://docs.aws.amazon.com/eks/latest/userguide/eks-add-ons.html 
* EBS CSI driver: manages the lifecycle of Amazon EBS volumes as storage for the Kubernetes Volumes that you create (generic ephemeral volumes and persistent volumes) [Reference](https://docs.aws.amazon.com/eks/latest/userguide/ebs-csi.html)
* EKS-managed node groups: node groups automate the provisioning and lifecycle management of nodes (Amazon EC2 instances) for Amazon EKS Kubernetes clusters. [Reference](https://docs.aws.amazon.com/eks/latest/userguide/managed-node-groups.html) [API reference](https://docs.aws.amazon.com/eks/latest/APIReference/API_Nodegroup.html)
* IAM assumable role with OIDC: Creates single IAM role which can be assumed by trusted resources using OpenID Connect Federated Users [Reference](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_oidc.html)

## Accessing the cluster

```bash
aws eks update-kubeconfig --name <cluster-name>
aws eks describe-cluster --name <cluster-name> 
# Access the cluster using kubectl
kubectl get nodes
```