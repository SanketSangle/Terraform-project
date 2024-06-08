provider "aws" {
  region     = "us-east-1"
  access_key = "AKIAZI2LDIA6R5MOGU6U"  #Enter your access key and secret access key
  secret_key = ""
}

resource "aws_instance" "my_project_instance" {
  ami           = "ami-07bdefe31ad285925"  #Enter your custom ami id
  instance_type = "t2.micro"

  # Specify a key pair if you need SSH access
  key_name = "instancekey"

  # Security group to allow HTTP, HTTPS, and MySQL access
  vpc_security_group_ids = [aws_security_group.my_project_sg.id]

  # Provisioners to start the project
  provisioner "remote-exec" {
    inline = [
      "sudo chmod 700 /home/ec2-user/apache-tomcat-8.5.100/bin/catalina.sh",
      "sudo /home/ec2-user/apache-tomcat-8.5.100/bin/catalina.sh start",
      "sudo systemctl start nginx",
      "sudo systemctl enable nginx"
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("C:/Users/Admin/Downloads/instancekey.pem")  #Enter path to your aws key file
      host        = self.public_ip
    }
  }

  tags = {
    Name = "MyProjectInstance"
  }
}

resource "aws_security_group" "my_project_sg" {
  name        = "my_project_sg"
  description = "Allow HTTP, HTTPS, and MySQL traffic"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3306
    to_port     = 3306
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
