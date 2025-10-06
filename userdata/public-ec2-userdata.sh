#!/bin/bash
# Public EC2 User Data (Bastion) with injected private key

set -e

LOG_FILE="/var/log/userdata.log"
exec > >(tee -a $LOG_FILE | logger -t user-data -s 2>/dev/console) 2>&1

echo "Starting Public EC2 setup..."

# Update system
sudo apt update -y && sudo apt upgrade -y

# Install utilities
sudo apt install -y curl unzip python3 python3-pip git jq telnet awscli

# Install AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install --update

# Create scripts directory
sudo mkdir -p /home/ubuntu/scripts
sudo chown ubuntu:ubuntu /home/ubuntu/scripts

# Inject private key content from Terraform variable
PRIVATE_KEY_CONTENT="${private_key_content}"

mkdir -p /home/ubuntu/.ssh
echo "$PRIVATE_KEY_CONTENT" > /home/ubuntu/.ssh/id_rsa
chmod 600 /home/ubuntu/.ssh/id_rsa
chown ubuntu:ubuntu /home/ubuntu/.ssh/id_rsa

# Create SSH connection script to private EC2
cat << EOF | sudo tee /home/ubuntu/scripts/connect_to_private.sh > /dev/null
#!/bin/bash
PRIVATE_IP="${private_ec2_ip}"

if [ -z "\$PRIVATE_IP" ]; then
  echo "Private EC2 IP not provided!"
  exit 1
fi

ssh -o StrictHostKeyChecking=no -i /home/ubuntu/.ssh/id_rsa ubuntu@\$PRIVATE_IP
EOF

sudo chmod +x /home/ubuntu/scripts/connect_to_private.sh
sudo chown ubuntu:ubuntu /home/ubuntu/scripts/connect_to_private.sh

echo "Public EC2 setup complete."
