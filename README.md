# AWS EKS CAST AI Configuration

This repository contains a reference CAST AI Configuration for
[Crossplane](https://crossplane.io). It's a great starting point for
building internal cloud platforms with autoscaling and offering a
self-service API to your internal development teams.

This platform offers APIs for setting up fully configured CAST AI
solution with Node Configuration, Node Templates, Autoscaler policies,
and all Castware components such as `castai-agent`,
`castai-cluster-controller`, `castai-evictor`, `castai-spot-handler`.
All these components are built using cloud service tools from the
[Official Upbound AWS Provider](https://marketplace.upbound.io/providers/upbound/provider-family-aws/) and
[Partner Upbound CAST AI Provider](https://marketplace.upbound.io/providers/crossplane-contrib/crossplane-provider-castai)

## Quickstart

### Prerequisites

- CAST AI account
- CAST AI Credentials
- AWS Credentials

### Configure the CAST AI provider

Before we can use the reference configuration we need to configure it with CAST AI FullAccess API Access Key:
- Obtained CAST AI [API Access Key](https://docs.cast.ai/docs/authentication#obtaining-api-access-key)

```console
# Create Secret with CAST AI API Access Key
cat <<EOF | ${KUBECTL} apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: castai-creds
  namespace: upbound-system
type: Opaque
stringData:
  credentials: |
    {
      "api_token": "y0ur-t0k3n",
      "api_url": "https://api.cast.ai"
    }
EOF

# Configure the CAST AI Provider to use the secret:
kubectl apply -f examples/castai-default-provider.yaml
```

### Configure the AWS provider

Before we can use the reference configuration we need to configure it with AWS
credentials:

```console
# Create a creds.conf file with the aws cli:
AWS_PROFILE=default && echo -e "[default]\naws_access_key_id = $(aws configure get aws_access_key_id --profile $AWS_PROFILE)\naws_secret_access_key = $(aws configure get aws_secret_access_key --profile $AWS_PROFILE)" > creds.conf

# Create a K8s secret with the AWS creds:
kubectl create secret generic aws-creds -n upbound-system --from-file=credentials=./creds.conf

# Configure the AWS Provider to use the secret:
kubectl apply -f examples/aws-default-provider.yaml
```


## Using the AWS EKS CAST AI Configuration

Create the Configuration:
```console
kubectl apply -f examples/configuration.yaml
```

Create Cluster in ReadOnly mode:
```console
kubectl apply -f examples/readonly.yaml
```

Upgrade Cluster to FullAccess mode:
```console
kubectl apply -f examples/fullaccess.yaml
```

🎉 Congratulations. You have just installed your CAST AI configuration!

## Overview

```
crossplane beta trace xfullaccess configuration-aws-eks-castai
NAME                                                                              SYNCED   READY   STATUS      
XFullAccess/configuration-aws-eks-castai                                          True     True    Available   
├─ XReadOnly/configuration-aws-eks-castai                                         True     True    Available   
│  ├─ EksCluster/configuration-aws-eks-castai-5xn9p                               True     True    Available   
│  └─ Release/configuration-aws-eks-castai-fbklv                                  True     True    Available   
├─ AutoScaler/configuration-aws-eks-castai-md5bq                                  True     True    Available   
├─ EksClusterId/configuration-aws-eks-castai-jcblz                                True     True    Available   
├─ EksUserArn/configuration-aws-eks-castai-wlqmt                                  True     True    Available   
├─ NodeConfigurationDefault/configuration-aws-eks-castai-8mgsm                    True     True    Available   
├─ NodeConfiguration/configuration-aws-eks-castai-8nf8j                           True     True    Available   
├─ NodeTemplate/configuration-aws-eks-castai-xmxtf                                True     True    Available   
├─ Release/configuration-aws-eks-castai-92869                                     True     True    Available   
├─ Release/configuration-aws-eks-castai-d6gh2                                     True     True    Available   
├─ Release/configuration-aws-eks-castai-h2zg8                                     True     True    Available   
├─ InstanceProfile/cast-eks-configuration-aws-eks-castai-j4xvc-instance-profile   True     True    Available   
├─ Policy/cast-eks-configuration-aws-eks-castai-j4xvc-cluster-policy              True     True    Available   
├─ Policy/cast-eks-configuration-aws-eks-castai-j4xvc-cluster-policy-restricted   True     True    Available   
├─ RolePolicyAttachment/configuration-aws-eks-castai-6bd2w                        True     True    Available   
├─ RolePolicyAttachment/configuration-aws-eks-castai-6jdrp                        True     True    Available   
├─ RolePolicyAttachment/configuration-aws-eks-castai-ljf72                        True     True    Available   
├─ RolePolicyAttachment/configuration-aws-eks-castai-vsxg8                        True     True    Available   
├─ RolePolicyAttachment/configuration-aws-eks-castai-w5npj                        True     True    Available   
├─ RolePolicyAttachment/configuration-aws-eks-castai-x2vnw                        True     True    Available   
├─ RolePolicyAttachment/configuration-aws-eks-castai-xkzhx                        True     True    Available   
├─ Role/cast-eks-configuration-aws-eks-castai-j4xvc-cluster-role                  True     True    Available   
└─ Role/cast-eks-configuration-aws-eks-castai-j4xvc-instance-profile              True     True    Available 
```

## Questions?

For any questions, thoughts and comments don't hesitate to [reach
out](https://www.upbound.io/contact) or drop by
[slack.crossplane.io](https://slack.crossplane.io), and say hi!
