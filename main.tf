locals {
    azs = data.aws_availability_zones.available.names
}

data "aws_availability_zones" "available" {}


resource "random_id" "random" {
    byte_length = 2
}

resource "aws_vpc" "cg_vpc" {
    cidr_block = var.vpc_cidr
    enable_dns_hostnames = true
    enable_dns_support = true
    
    tags = {
        Name = "cg_vpc-${random_id.random.dec}"
    }
    lifecycle {
        create_before_destroy = true   # destroys vpc before creating new one
    }
}

resource "aws_internet_gateway" "cg_internet_gateway" {
    vpc_id = aws_vpc.cg_vpc.id 
    
    tags = {
        Name = "cg_igw-${random_id.random.dec}"
    }
}

resource "aws_route_table" "cg_public_rt" { # lets enhance security :)
    vpc_id = aws_vpc.cg_vpc.id
    
    tags = {
        Name = "cg-public"
    }
}

resource "aws_route" "default_route" {
    route_table_id = aws_route_table.cg_public_rt.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.cg_internet_gateway.id
}

resource "aws_default_route_table" "cg_private_rt" {
    default_route_table_id = aws_vpc.cg_vpc.default_route_table_id
    
    tags = {
        Name = "cg_private"
    }
}

resource "aws_subnet" "cg_public_subnet" {
    count = length(local.azs)
    vpc_id = aws_vpc.cg_vpc.id
    cidr_block = cidrsubnet(var.vpc_cidr, 8, count.index)
    map_public_ip_on_launch = true # any instance deployed on this subnet will have public ip
    availability_zone = local.azs[count.index]
    
    tags = {
        Name = "cg-public-${count.index + 1}"
    }
}

resource "aws_subnet" "cg_private_subnet" {
    count = length(local.azs)
    vpc_id = aws_vpc.cg_vpc.id
    cidr_block = cidrsubnet(var.vpc_cidr, 8, length(local.azs) + count.index)
    map_public_ip_on_launch = false 
    availability_zone = local.azs[count.index]
    
    tags = {
        Name = "cg-private-${count.index + 1}"
    }
}

