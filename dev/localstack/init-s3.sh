#!/usr/bin/env bash
# LocalStack ready-hook: creates the product-images S3 bucket
# on first startup. This script is mounted read-only at
# /etc/localstack/init/ready.d/ and executed by LocalStack
# once all enabled services are initialised.

set -euo pipefail

BUCKET="${PRODUCT_IMAGE_BUCKET_NAME:-product-images}"

echo "LocalStack init: ensuring S3 bucket '${BUCKET}' exists..."

if awslocal s3api head-bucket --bucket "${BUCKET}" 2>/dev/null; then
  echo "Bucket '${BUCKET}' already exists — skipping creation."
else
  awslocal s3api create-bucket --bucket "${BUCKET}"
  echo "Bucket '${BUCKET}' created successfully."
fi
