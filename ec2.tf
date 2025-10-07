##############################################
# Public EC2 Instance
##############################################
resource "aws_instance" "ec2-public1" {
  ami                         = "ami-00271c85bf8a52b84"
  instance_type               = var.instance_name
  subnet_id                   = aws_subnet.public_subnet1.id
  key_name                    = var.key_pair_name
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.public_ec2_sg.id]

  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name

  # Simple remote-exec to confirm SSH works
  provisioner "remote-exec" {
    inline = ["echo 'Hello from Public EC2 - SSH working fine'"]
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = var.private_key_content
      host        = self.public_ip
    }
  }

  # Pass private EC2 details to public EC2 via user_data
  user_data = templatefile("${path.module}/userdata/public-ec2-userdata.sh", {
    private_ec2_ip      = aws_instance.ec2-private1.private_ip
    private_key_content = var.private_key_content
  })

  tags = {
    Name       = "${var.project_name}-ec2_public1"
    Managed_by = var.managed_by
  }

  depends_on = [aws_internet_gateway.igw1]
}

##############################################
# Private EC2 Instance (Fixed Connection)
##############################################
resource "aws_instance" "ec2-private1" {
  ami                    = "ami-00271c85bf8a52b84"
  instance_type          = var.instance_name
  subnet_id              = aws_subnet.private_subnet1.id
  key_name               = var.key_pair_name
  vpc_security_group_ids = [aws_security_group.private_ec2_sg.id]

  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name

  # ✅ FIXED: Connect through bastion (public EC2)
  provisioner "remote-exec" {
    inline = [
      "echo 'Connected to Private EC2 via Bastion successfully!'",
      "sudo apt update -y",
      "sudo apt install -y awscli"
    ]

    connection {
      type                = "ssh"
      user                = "ubuntu"
      private_key         = var.private_key_content
      host                = self.private_ip
      # 👇 These 3 lines fix your timeout issue
      bastion_host        = aws_instance.ec2-public1.public_ip
      bastion_user        = "ubuntu"
      bastion_private_key = var.private_key_content
    }
  }

  # Optional user_data (kept as you had)
  user_data = templatefile("${path.module}/userdata/private-ec2-userdata.sh", {
    s3_bucket_name       = var.s3_bucket_name
    private_key_content  = var.private_key_content
  })

  tags = {
    Name       = "${var.project_name}-ec2_private1"
    Managed_by = var.managed_by
  }

  depends_on = [aws_nat_gateway.nat1]
}
