# Public EC2
resource "aws_instance" "ec2-public1" {
  ami                         = "ami-00271c85bf8a52b84"
  instance_type               = var.instance_name
  subnet_id                   = aws_subnet.public_subnet1.id
  key_name                    = var.key_pair_name
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.public_ec2_sg.id]

  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name

  # Example provisioner
  provisioner "remote-exec" {
    inline = ["echo Hello from Public EC2"]
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = var.private_key_content
      host        = self.public_ip
    }
  }

  user_data = templatefile("${path.module}/userdata/public-ec2-userdata.sh", {
    private_ec2_ip = aws_instance.ec2-private1.private_ip
    private_key_content = var.private_key_content
  })

  tags = {
    Name       = "${var.project_name}-ec2_public1"
    Managed_by = var.managed_by
  }

  depends_on = [aws_internet_gateway.igw1]
}


# Private EC2
resource "aws_instance" "ec2-private1" {
  ami                    = "ami-00271c85bf8a52b84"
  instance_type          = var.instance_name
  subnet_id              = aws_subnet.private_subnet1.id
  key_name               = var.key_pair_name
  vpc_security_group_ids = [aws_security_group.private_ec2_sg.id]

  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name
  
  provisioner "remote-exec" {
  inline = ["echo Hello from Private EC2"]
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = var.private_key_content
    host        = self.private_ip
  }
}

  user_data = templatefile("${path.module}/userdata/private-ec2-userdata.sh", {
    s3_bucket_name = var.s3_bucket_name
    private_key_content = var.private_key_content   # if used in template
  })

  tags = {
    Name       = "${var.project_name}-ec2_private1"
    Managed_by = var.managed_by
  }

  depends_on = [aws_nat_gateway.nat1]
}
