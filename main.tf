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
}

resource "aws_internet_gateway" "cg_internet_gateway" {
    vpc_id = aws_vpc.cg_vpc.id 
    
    tags = {
        Name = "cg_igw-${random_id.random.dec}"
    }
}