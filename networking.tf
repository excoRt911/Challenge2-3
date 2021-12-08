
#Delivering provider use

provider "aws" {
    region = var.aws_region
    shared_credentials_file = "%USERPROFILE%/.aws/credentials"
    }

#Creating VPC
resource "aws_vpc" "main-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
      Name = "Main VPC"
  }
}

#Creating Internet Gateway
resource "aws_internet_gateway" "main-gw" {
  vpc_id = aws_vpc.main-vpc.id

  tags = {
    Name = "Main Internet Gateway"
  }
 }

#Creating NAT Gateway
resource "aws_nat_gateway" "nat-gateway-1" {
  allocation_id = aws_eip.natgw-public-ip-1.id
  subnet_id = aws_subnet.public-subnet-1.id
  tags = {
    Name = "Nat Gateway - 1" 
  }
}


resource "aws_nat_gateway" "nat-gateway-2" {
  allocation_id = aws_eip.natgw-public-ip-2.id
  subnet_id = aws_subnet.public-subnet-2.id
  tags = {
    Name = "Nat Gateway - 2"
  }
}

#Creating NAT Gateway EIP for both nat gateways
resource "aws_eip" "natgw-public-ip-1" {
  vpc = true

  tags = {
    Name = "eip1"
  }
}

resource "aws_eip" "natgw-public-ip-2" {
  vpc = true

  tags = {
    Name = "eip2"
  }
}


#Creating Subnets

#Public Subnets
resource "aws_subnet" "public-subnet-1" {
  vpc_id = aws_vpc.main-vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "Public Subnet 1"
  }
}

resource "aws_subnet" "public-subnet-2" {
  vpc_id = aws_vpc.main-vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "Public Subnet 2"
  }
}
#Private Subnets
resource "aws_subnet" "private-subnet-1" {
  vpc_id = aws_vpc.main-vpc.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "Private Subnet 1"
  }
}

resource "aws_subnet" "private-subnet-2" {
  vpc_id = aws_vpc.main-vpc.id
  cidr_block = "10.0.4.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "Private Subnet 2"
  }
}

#Creating Routing Tables
resource "aws_route_table" "public-routing-table" {
  vpc_id = aws_vpc.main-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main-gw.id
  }
  tags = {
    Name = "Public Routing Table"
  }
}

resource "aws_route_table" "private-routing-table-1" {
  vpc_id = aws_vpc.main-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat-gateway-1.id
    }
  tags = {
    Name = "Private Routing Table 1"
  }
}
resource "aws_route_table" "private-routing-table-2" {
  vpc_id = aws_vpc.main-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat-gateway-2.id
    }
  tags = {
    Name = "Private Routing Table 2"
  }
}

#routing table assosiations
resource "aws_route_table_association" "public_subnet_1_assosication" {
  subnet_id = aws_subnet.public-subnet-1.id
  route_table_id = aws_route_table.public-routing-table.id
}
resource "aws_route_table_association" "public_subnet_2_assosication" {
  subnet_id = aws_subnet.public-subnet-2.id
  route_table_id = aws_route_table.public-routing-table.id
}
resource "aws_route_table_association" "private_subnet_1_assosication" {
  subnet_id = aws_subnet.private-subnet-1.id
  route_table_id = aws_route_table.private-routing-table-1.id
}
resource "aws_route_table_association" "private_subnet_2_assosication" {
  subnet_id = aws_subnet.private-subnet-2.id
  route_table_id = aws_route_table.private-routing-table-2.id
}



