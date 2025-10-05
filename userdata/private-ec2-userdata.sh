#!/bin/bash
# Private EC2 User Data for Ubuntu

set -e

LOG_FILE="/var/log/userdata.log"
# Escape $LOG_FILE so Terraform doesn't try to replace it
exec > >(tee -a \$LOG_FILE | logger -t user-data -s 2>/dev/console) 2>&1

echo "Starting Private EC2 setup..."

# Update system
sudo apt update -y && sudo apt upgrade -y

# Install utilities
sudo apt install -y curl unzip python3 python3-pip git jq awscli

# Install AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install --update

# Create scripts directory
sudo mkdir -p /home/ubuntu/scripts
sudo chown ubuntu:ubuntu /home/ubuntu/scripts

# Create S3 test script
cat << EOF | sudo tee /home/ubuntu/scripts/test_s3.sh > /dev/null
#!/bin/bash
BUCKET_NAME="${s3_bucket_name}"   # Terraform variable

echo "Testing S3 access for bucket: \$BUCKET_NAME"
aws s3 mb s3://\$BUCKET_NAME 2>/dev/null || echo "Bucket exists or permission denied."
echo "Test file" > /home/ubuntu/test_file.txt
aws s3 cp /home/ubuntu/test_file.txt s3://\$BUCKET_NAME/test-files/
aws s3 ls s3://\$BUCKET_NAME/test-files/ || echo "Cannot list files."
EOF

sudo chmod +x /home/ubuntu/scripts/test_s3.sh
sudo chown ubuntu:ubuntu /home/ubuntu/scripts/test_s3.sh

echo "Private EC2 setup complete."
