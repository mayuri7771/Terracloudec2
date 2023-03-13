provider "aws" {
  region     = "us-east-1"
  access_key = "AKIAR632IK56XZV7VPFQ"
  secret_key = "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"
}

resource "aws_instance" "ec2" {
  ami           = "ami-0557a15b87f6559cf" # us-east-1
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.mysubnet.id
  tags = {
    Name = "ec2"
  }

}
####VPC####
resource "aws_vpc" "myvpc" {
  cidr_block = "10.0.0.0/16"
}
####### vpc internet gatway #####
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.myvpc.id

  tags = {
    Name = "igw"
  }
}

#####Subnet###
resource "aws_subnet" "mysubnet" {
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "subnet"
  }
}

###Route Table #####

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.myvpc.id

  route = []

  tags = {
    Name = "rt"
  }
}

###Route#######
resource "aws_route" "route" {
  route_table_id         = aws_route_table.rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
  depends_on             = [aws_route_table.rt]
}
#####SecurityGrop####
resource "aws_security_group" "sg" {
  name        = "allow_all_traffic"
  description = "Allow all inbound traffic"
  vpc_id      = aws_vpc.myvpc.id

  ingress {
    description      = "all traffic"
    from_port        = 0    #all ports
    to_port          = 0    # all ports
    protocol         = "-1" #all traffic
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = null
    prefix_list_ids  = null
    security_groups  = null
    self             = null
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    description      = "outbound rule"
    prefix_list_ids  = null
    security_groups  = null
    self             = null
  }

  tags = {
    Name = "all_traffic"
  }
}

##########route table associate######
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.mysubnet.id
  route_table_id = aws_route_table.rt.id
}

##############EC2 Instance######################