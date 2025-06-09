provider "aws" {
  region = "ap-southeast-1"
}

resource "aws_vpc" "myvpc" {
  cidr_block = "10.0.0.0/16" #Create the ip range used in vpc
}

resource "aws_subnet" "public_subnet" {
  vpc_id = aws_vpc.myvpc.id
  cidr_block = "10.0.1.0/24"  #Create the ip range used in this subnet
  availability_zone = "ap-southeast-1a" #The AZ used in this subnet
  map_public_ip_on_launch = true #Give public ip for this subnet

  tags = {
    Name = "Public Subnet"
  } 
}

resource "aws_internet_gateway" "myigw" {
  vpc_id = aws_vpc.myvpc.id
  tags = {
    Name = "My Internet Gateway"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.myvpc.id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myigw.id
  }
    tags = {
    Name = "Public Route Table"
  }
}


resource "aws_route_table_association" "public_rt_assoc" {
  subnet_id = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id

}

resource "aws_eip" "natip" {
  domain = "vpc"
  tags = {
    Name = "Nat IP"
  }
} 

resource "aws_subnet" "private_subnet" {
  vpc_id = aws_vpc.myvpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "ap-southeast-1a"
  map_public_ip_on_launch = false

  tags = {
    Name = "Private Subnet"
  } 
}

resource "aws_nat_gateway" "mynatgw" {
  allocation_id = aws_eip.natip.id
  subnet_id = aws_subnet.public_subnet.id

  tags = {
    Name = "My Nat Gateway"
  }
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.myvpc.id
  
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.mynatgw.id
  }
}


resource "aws_route_table_association" "private_rt_assoc" {
  subnet_id = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_rt.id
}
