#!/bin/bash
# Bootstrap script to create S3 bucket and DynamoDB table for Terraform backend
# This script should be run once before using the main Terraform configuration

set -e

echo "=========================================="
echo "Terraform Backend Bootstrap"
echo "=========================================="
echo ""
echo "This script will create:"
echo "  - S3 bucket for Terraform state storage"
echo "  - DynamoDB table for state locking"
echo ""

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Default values (can be overridden with environment variables)
AWS_REGION="${AWS_REGION:-us-east-2}"
BUCKET_NAME="${BUCKET_NAME:-pedromendes-dev-us-east-2-tarraform-statefile}"
DYNAMODB_TABLE="${DYNAMODB_TABLE:-pedromendes-dev-us-east-2-terraform-lock}"

echo "Configuration:"
echo "  AWS Region: $AWS_REGION"
echo "  S3 Bucket: $BUCKET_NAME"
echo "  DynamoDB Table: $DYNAMODB_TABLE"
echo ""

# Check if AWS CLI is available
if ! command -v aws &> /dev/null; then
    echo "ERROR: AWS CLI is not installed. Please install it first."
    exit 1
fi

# Check if Terraform is available
if ! command -v terraform &> /dev/null; then
    echo "ERROR: Terraform is not installed. Please install it first."
    exit 1
fi

# Check AWS credentials
echo "Checking AWS credentials..."
if ! aws sts get-caller-identity > /dev/null 2>&1; then
    echo "ERROR: Unable to authenticate with AWS. Please configure your AWS credentials."
    echo "You can set them using:"
    echo "  - AWS CLI: aws configure"
    echo "  - Environment variables: AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY"
    echo "  - IAM role (if running on EC2/ECS)"
    exit 1
fi

ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
echo "✓ Authenticated as AWS Account: $ACCOUNT_ID"
echo ""

# Navigate to bootstrap directory
cd "$SCRIPT_DIR"

# Initialize Terraform
echo "Initializing Terraform..."
terraform init

# Plan the changes
echo ""
echo "Planning infrastructure changes..."
terraform plan \
    -var="aws_region=$AWS_REGION" \
    -var="bucket_name=$BUCKET_NAME" \
    -var="dynamodb_table_name=$DYNAMODB_TABLE" \
    -out=bootstrap.tfplan

# Ask for confirmation
echo ""
read -p "Do you want to apply these changes? (yes/no): " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    echo "Aborted by user."
    rm -f bootstrap.tfplan
    exit 0
fi

# Apply the changes
echo ""
echo "Creating infrastructure..."
terraform apply bootstrap.tfplan

# Clean up plan file
rm -f bootstrap.tfplan

echo ""
echo "=========================================="
echo "Bootstrap Complete!"
echo "=========================================="
echo ""
echo "The following resources have been created:"
terraform output

echo ""
echo "You can now run your main Terraform configuration with the remote backend."
echo ""
