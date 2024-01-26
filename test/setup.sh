#!/usr/bin/env bash
set -aeuo pipefail

echo "Running setup.sh"
echo "Waiting until configuration package is healthy/installed..."
"${KUBECTL}" wait configuration.pkg platform-ref-gcp --for=condition=Healthy --timeout 5m
"${KUBECTL}" wait configuration.pkg platform-ref-gcp --for=condition=Installed --timeout 5m
"${KUBECTL}" wait configurationrevisions.pkg --all --for=condition=Healthy --timeout 5m

echo "Waiting until all installed provider packages are healthy..."
"${KUBECTL}" wait provider.pkg --all --for condition=Healthy --timeout 5m

echo "Waiting for all pods to come online..."
"${KUBECTL}" -n upbound-system wait --for=condition=Available deployment --all --timeout=5m

echo "Waiting for all XRDs to be established..."
"${KUBECTL}" wait xrd --all --for condition=Established


if [[ -n "${UPTEST_CLOUD_CREDENTIALS:-}" ]]; then
#   UPTEST_CLOUD_CREDENTIALS may contain more than one cloud credentials that we expect to be provided
#   in a single GitHub secret. We expect them provided as key=value pairs separated by newlines. 
#   AWS='[default]
#   aws_access_key_id = REDACTED
#   aws_secret_access_key = REDACTED'
#   CASTAI='{
#   "api_token": "y0ur-t0k3n",
#   "api_url": "https://api.cast.ai"
#   }'
  eval "${UPTEST_CLOUD_CREDENTIALS}"

  if [[ -n "${AWS:-}" ]]; then
    echo "Creating the AWS default cloud credentials secret..."
    ${KUBECTL} -n upbound-system create secret generic aws-creds --from-literal=credentials="${AWS}" --dry-run=client -o yaml | ${KUBECTL} apply -f -

    echo "Creating the AWS default provider config..."
    cat <<EOF | ${KUBECTL} apply -f -
apiVersion: aws.upbound.io/v1beta1
kind: ProviderConfig
metadata:
  name: default
spec:
  credentials:
    source: Secret
    secretRef:
      name: aws-creds
      namespace: upbound-system
      key: credentials
EOF
  fi

  if [[ -n "${CASTAI:-}" ]]; then
    echo "Creating the CASTAI default cloud credentials secret..."
    ${KUBECTL} -n upbound-system create secret generic castai-creds --from-literal=credentials="${CASTAI}" --dry-run=client -o yaml | ${KUBECTL} apply -f -

    echo "Creating the CASTAI default provider config..."
    cat <<EOF | ${KUBECTL} apply -f -
apiVersion: castai.upbound.io/v1beta1
kind: ProviderConfig
metadata:
  name: default
spec:
  credentials:
    source: Secret
    secretRef:
      name: castai-creds
      namespace: upbound-system
      key: credentials
EOF
  fi
fi
