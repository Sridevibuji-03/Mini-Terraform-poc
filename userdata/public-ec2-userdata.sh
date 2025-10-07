#!/bin/bash
# User data for public EC2 (Bastion host) - Ubuntu version

# Update all packages
sudo apt-get update -y && sudo apt-get upgrade -y

# Install common tools
sudo apt-get install -y curl unzip awscli python3 python3-pip git jq telnet

# Install latest AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install --update

# Create scripts directory
mkdir -p /home/ubuntu/scripts

# Script to connect to private EC2
cat << 'EOF' > /home/ubuntu/scripts/connect_to_private.sh
#!/bin/bash
if [ $# -eq 0 ]; then
    echo "Usage: $0 <private-instance-ip>"
    exit 1
fi
ssh -o StrictHostKeyChecking=no -i /home/ubuntu/.ssh/id_rsa ubuntu@$1
EOF

chmod +x /home/ubuntu/scripts/connect_to_private.sh
chown -R ubuntu:ubuntu /home/ubuntu/scripts

echo "Public EC2 instance setup complete!"
