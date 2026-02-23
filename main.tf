variable "vpc_cidr" {
  type = string
}
variable "vpc_name" {
  type = string
}
variable "public_subnet_cidr" {
  type = string
}
variable "private_subnet_cidr" {
  type = string
}
variable "az" {
  type = string
}
# Create a VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = var.vpc_name
  }
}
# Subnet for public resources
resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = var.public_subnet_cidr
  availability_zone = var.az
  tags = {
    Name = "${var.vpc_name}-public-subnet"
  }
}
resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = var.private_subnet_cidr
  availability_zone = var.az
  tags = {
    Name = "${var.vpc_name}-private-subnet"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "${var.vpc_name}-internet-gateway"
  }
}
# Route Table for public subnet
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "${var.vpc_name}-public-rt"
  }
}
# Route to Internet Gateway
resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.my_igw.id
}
# Associate public subnet with route table
resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

