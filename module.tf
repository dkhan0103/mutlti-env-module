# Terraform Config file (main.tf). This has provider block (AWS) and config for provisioning one EC2 instance resource.  

terraform {
required_providers {
  aws = {
  source = "hashicorp/aws"
  version = ">= 3.27"
 }
}

  required_version = ">=0.14"
} 
provider "aws" {
  profile = "default"
  region = "us-east-1"
}

# Define tags locally
locals {
  default_tags = merge(var.default_tags, { "environment" = var.environment })
}

# Data source for availability zones in us-east-1
data "aws_availability_zones" "available" {
  state = "available"
}



# Create VPC
resource "aws_vpc" "vpc-non-prod" {
  count = var.environment == "nonprod" ? 1 : 0

  cidr_block = "10.1.0.0/16"

   tags = merge(
    local.default_tags, {
      Name = "${var.environment}-VPC"
    }
  )
}

resource "aws_vpc" "vpc-prod" {
  count = var.environment == "prod" ? 1 : 0

  cidr_block = "10.10.0.0/16"

 tags = merge(
    local.default_tags, {
      Name = "${var.environment}-VPC"
    }
  )
}

# Create private subnets
resource "aws_subnet" "private" {
  count = length(var.nonprod_private_subnet_cidrs)

  cidr_block = var.nonprod_private_subnet_cidrs[count.index]
  vpc_id     = var.environment == "nonprod" ? aws_vpc.vpc-non-prod[0].id : aws_vpc.vpc-prod[0].id

  tags = merge(
    local.default_tags, {
      Name = "${var.environment}-private-subnet-${count.index + 1}"
    }
  )
}

resource "aws_subnet" "prod_private" {
  count = var.environment == "prod" ? length(var.prod_private_subnet_cidrs) : 0

  cidr_block = var.prod_private_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[1]
  vpc_id     = aws_vpc.vpc-prod[0].id

  tags = merge(
    local.default_tags, {
      Name = "${var.environment}-private-subnet-${count.index + 1}"
    }
  )
}

# Create public subnets
resource "aws_subnet" "public" {
  count = var.environment == "nonprod" ? length(var.public_cidr_blocks) : 0

  cidr_block = var.public_cidr_blocks[count.index]
  vpc_id     = var.environment == "nonprod" ? aws_vpc.vpc-non-prod[0].id : aws_vpc.vpc-prod[0].id

 tags = merge(
    local.default_tags, {
      Name = "${var.environment}-public-subnet-${count.index + 1}"
    }
  )
}

# Create internet gateway
resource "aws_internet_gateway" "gw-non-prod" {
  count = var.environment == "nonprod" ? 1 : 0

  vpc_id = aws_vpc.vpc-non-prod[0].id

  tags = merge(local.default_tags,
    {
      "Name" = "${var.environment}-igw"
    }
  )
}


# Create internet gateway
resource "aws_internet_gateway" "gw-prod" {
  count = var.environment == "prod" ? 1 : 0

  vpc_id = aws_vpc.vpc-prod[0].id

  tags = merge(local.default_tags,
    {
      "Name" = "${var.environment}-igw"
    }
  )
}

# Create public route table and association
resource "aws_route_table" "public" {
  count = var.environment == "nonprod" ? 1 : 0

  vpc_id = aws_vpc.vpc-non-prod[0].id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw-non-prod[count.index].id
  }

  tags = {
    Name = "${var.environment}-route-public-subnets"
  }
}


resource "aws_route_table_association" "public" {
  count = var.environment == "nonprod" ? 2 : 0

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public[0].id

}







# Create private route table and association
resource "aws_route_table" "private" {
  count = var.environment == "prod" ? 1 : 0

  vpc_id = aws_vpc.vpc-prod[0].id
  
  

  tags = {
    Name = "${var.environment}-route-table"
  }
}

resource "aws_route_table_association" "private" {
  count = var.environment == "prod" ? 2 : 0

  subnet_id      = aws_subnet.prod_private[count.index].id
  route_table_id = aws_route_table.private[0].id

}






