# Create AWS VPC
resource "aws_vpc" "customvpc" {
  cidr_block = "10.0.0.0/16"
  instance_tenancy = "default"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags= {
      Name= "customvpc"
  }
}

#Create Subnet in the custom vpc
resource "aws_subnet" "customvpc-public-1" {
  vpc_id = aws_vpc.customvpc.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = "ap-southeast-2a"

  tags = {
      Name = "customvpc-public-1"
  }
}

#Create Subnet in the custom vpc
resource "aws_subnet" "customvpc-public-2" {
  vpc_id = aws_vpc.customvpc.id
  cidr_block = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone = "ap-southeast-2b"

  tags = {
      Name = "customvpc-public-2"
  }
}

#Create Subnet in the custom vpc
resource "aws_subnet" "customvpc-private-1" {
  vpc_id = aws_vpc.customvpc.id
  cidr_block = "10.0.3.0/24"
  map_public_ip_on_launch = false
  availability_zone = "ap-southeast-2b"

  tags = {
      Name = "customvpc-private-1"
  }
}

#Create Subnet in the custom vpc
resource "aws_subnet" "customvpc-private-2" {
  vpc_id = aws_vpc.customvpc.id
  cidr_block = "10.0.4.0/24"
  map_public_ip_on_launch = false
  availability_zone = "ap-southeast-2c"

  tags = {
      Name = "customvpc-private-2"
  }
}

# Define Internet Gateway
resource "aws_internet_gateway" "customvpc-ig" {
  vpc_id = aws_vpc.customvpc.id

  tags = {
      Name = "customvpc-ig"
  }
}

#Define Routing Table for custom VPC
resource "aws_route_table" "customvpc-r" {
  vpc_id = aws_vpc.customvpc.id

  route {
      cidr_block = "0.0.0.0/0" #all IPs
      gateway_id = aws_internet_gateway.customvpc-ig.id
  }

  tags = {
    Name = "Customvpc-public-r"
  }
}

#Define routing association between a route table
# and a subnet or a route table and ig or virtual private gateway

resource "aws_route_table_association" "customvpc-public-1-a" {
  subnet_id = aws_subnet.customvpc-public-1.id
  route_table_id = aws_route_table.customvpc-r.id
}

resource "aws_route_table_association" "customvpc-public-2-a" {
  subnet_id = aws_subnet.customvpc-public-2.id
  route_table_id = aws_route_table.customvpc-r.id
}
