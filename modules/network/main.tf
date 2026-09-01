
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(
    {
      Name        = "${var.env}-vpc"
    },
    var.common_tags
  )
}

##########################################
# Internet Gateway
##########################################
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = var.common_tags
}

##########################################
# Public Subnets
##########################################
resource "aws_subnet" "public_subnets" {
  count                   = length(var.availability_zones)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = locals.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = merge(
    {
      Name        = "${var.env}-public-subnet${count.index}"
    },
    var.common_tags
  )
}

##########################################
# Private Subnets for Applications
##########################################
resource "aws_subnet" "private_app_subnets" {
  count             = length(var.availability_zones)
  vpc_id            = aws_vpc.main.id
  cidr_block        = locals.private_app_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = merge(
    {
      Name        = "${var.env}-private-app-subnet${count.index}"
      Environment = var.env
    },
    var.common_tags
  )
}

##########################################
# Elastic IPs for NAT Gateway
##########################################
resource "aws_eip" "nat_eips" {
  count         = var.enable_ha ? length(var.availability_zones) : 1
  domain = "vpc"

  tags = var.common_tags
}

##########################################
# NAT Gateways
##########################################
resource "aws_nat_gateway" "nat_gateways" {
  count         = var.enable_ha ? length(var.availability_zones) : 1
  allocation_id = aws_eip.nat_eips[count.index].id
  subnet_id     = aws_subnet.public_subnets[count.index].id

  tags = merge(
    {
      Name        = "${var.env}-nat-gateway-az${count.index}"
    },
    var.common_tags
  )

  depends_on = [aws_internet_gateway.main]
}

##########################################
# Route Tables
##########################################
# Public route table
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = var.common_tags
}

# Private route tables
resource "aws_route_table" "private_route_tables" {
  count  = length(var.availability_zones)
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateways[count.index].id
  }

  tags = var.common_tags
}

##########################################
# Route Table Associations
##########################################
# Public subnets associations
resource "aws_route_table_association" "public_subnet_associations" {
  count          = length(var.availability_zones)
  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}

# Private app subnets associations
resource "aws_route_table_association" "private_app_subnet_associations" {
  count          = length(var.availability_zones)
  subnet_id      = aws_subnet.private_app_subnets[count.index].id
  route_table_id = aws_route_table.private_route_tables[count.index].id
}