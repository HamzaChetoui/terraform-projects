provider "aws" {
  region = "us-east-1"
}

resource "aws_security_group" "sg" {
  name        = "sg"
  description = "Allow TCP/80 & TCP/22"
  ingress {
    description = "Allow SSH traffic"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "allow traffic from TCP/80"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "web" {
  ami                     = "ami-0ed9277fb7eb570c9"
  instance_type           = "t2.micro"
  key_name                = "aws_key"
  vpc_security_group_ids  = [aws_security_group.sg.id]
  tags = {
    Name = "myinstance"
  }

  provisioner "remote-exec" {
    connection {
       type        = "ssh"
       user        = "ec2-user"
       private_key = file("/home/cloud_user/aws_key.pem")
       host        = self.public_ip
    }
    inline = [
      "sudo yum -y install httpd && sudo systemctl start httpd",
      "echo '<h1><center>My Test Website With Help From Terraform Provisioner</center></h1>' > index.html",
      "sudo mv index.html /var/www/html/"
    ]
  }
}
output "test" {
  value = aws_instance.web.public_ip
}
