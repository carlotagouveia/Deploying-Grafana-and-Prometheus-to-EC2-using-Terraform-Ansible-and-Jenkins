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