data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "ravi" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.i_type
  availability_zone      = var.avlb_zn
  vpc_security_group_ids = [aws_security_group.the_sg.id]
  key_name               = aws_key_pair.this.key_name
  #volume_type = ""
  user_data              = local.user_data
  #count                  = 1


  tags = {
    Name = "${var.tag}_instance"
  
  }
}

### security group create ###
resource "aws_security_group" "the_sg" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    description = "TLS from VPC"
    from_port   = 22
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${var.tag}_security_group"
  }
} 


### key create ###
resource "tls_private_key" "ravi_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "this" {
  key_name   = "imp_ravi-key"
  public_key = tls_private_key.ravi_key.public_key_openssh
}


## Elastic ip ##
resource "aws_eip" "elastic_ip" {
  instance = aws_instance.ravi.id
  vpc      = true
}

####EFS file system ####
resource "aws_efs_file_system" "this" {
  creation_token = "${var.tag}_efs"
  encrypted = true
  tags = {
    Name = "${var.tag}_efs"
  }
}

## EFS file mount ##
resource "aws_efs_mount_target" "this" {
  file_system_id = aws_efs_file_system.this.id
  subnet_id      = "subnet-02256444dc444d97d"
  security_groups = [aws_security_group.the_sg.id]
}


##EFS file access point ##
resource "aws_efs_access_point" "this" {
  file_system_id = aws_efs_file_system.this.id
}