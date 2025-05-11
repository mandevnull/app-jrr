# VPC
resource "aws_vpc" "vpc_jrr" {
  cidr_block           = "192.168.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "vpc-jrr"
  }
}

# INTERNET GW (PUBLIC SUBNETS)
resource "aws_internet_gateway" "igw_jrr" {
  vpc_id = aws_vpc.vpc_jrr.id

  tags = {
    Name = "igw-jrr"
  }
}

# PUBLIC SUBNETS (2 AZ)
resource "aws_subnet" "public_1_jrr" {
  vpc_id                  = aws_vpc.vpc_jrr.id
  cidr_block              = "192.168.1.0/24"
  availability_zone       = "eu-west-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-1-jrr"
  }
}

resource "aws_subnet" "public_2_jrr" {
  vpc_id                  = aws_vpc.vpc_jrr.id
  cidr_block              = "192.168.0.0/24"
  availability_zone       = "eu-west-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-2-jrr"
  }
}


# PRIVATE SUBNETS (2 AZ)
resource "aws_subnet" "private_1_jrr" {
  vpc_id            = aws_vpc.vpc_jrr.id
  cidr_block        = "192.168.2.0/24"
  availability_zone = "eu-west-1a"

  tags = {
    Name = "private-1-jrr"
  }
}

resource "aws_subnet" "private_2_jrr" {
  vpc_id            = aws_vpc.vpc_jrr.id
  cidr_block        = "192.168.3.0/24"
  availability_zone = "eu-west-1b"

  tags = {
    Name = "private-2-jrr"
  }
}

# ROUTE TABLE PUBLIC SUBNET
resource "aws_route_table" "public_rt_jrr" {
  vpc_id = aws_vpc.vpc_jrr.id

  tags = {
    Name = "public-rt-jrr"
  }
}

resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.public_rt_jrr.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw_jrr.id
}

resource "aws_route_table_association" "public_1_assoc" {
  subnet_id      = aws_subnet.public_1_jrr.id
  route_table_id = aws_route_table.public_rt_jrr.id
}

resource "aws_route_table_association" "public_2_assoc" {
  subnet_id      = aws_subnet.public_2_jrr.id
  route_table_id = aws_route_table.public_rt_jrr.id
}


# NAT GW (PRIVATE SUBNETS)
resource "aws_eip" "nat_eip_jrr" {

  tags = {
    Name = "nat-eip-jrr"
  }
}

resource "aws_nat_gateway" "nat_jrr" {
  allocation_id = aws_eip.nat_eip_jrr.id
  subnet_id     = aws_subnet.public_1_jrr.id

  tags = {
    Name = "nat-gw-jrr"
  }
}

# ROUTE TABLES PRIVATE SUBNETS
resource "aws_route_table" "private_rt_jrr" {
  vpc_id = aws_vpc.vpc_jrr.id

  tags = {
    Name = "private-rt-jrr"
  }
}

resource "aws_route" "private_nat_access" {
  route_table_id         = aws_route_table.private_rt_jrr.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_jrr.id
}

resource "aws_route_table_association" "private_1_assoc" {
  subnet_id      = aws_subnet.private_1_jrr.id
  route_table_id = aws_route_table.private_rt_jrr.id
}

resource "aws_route_table_association" "private_2_assoc" {
  subnet_id      = aws_subnet.private_2_jrr.id
  route_table_id = aws_route_table.private_rt_jrr.id
}
