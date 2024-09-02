data "aws_ami" "server_ami" {
    most_recent = true
    
    owners = ["099720109477"]
    
    filter {
        name = "name"
        values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
    }
}

resource "aws_instance" "cg_main" {
    instance_type = var.main_instance_type
    ami = data.aws_ami.server_ami.id
    # key_name = ""
    vpc_security_group_ids = [aws_security_group.cg_sg.id]
    subnet_id = aws_subnet.cg_public_subnet[0].id
    root_block_device {
        volume_size = var.main_vol_size
    }
    
    tags = {
        Name = "cg-main"
    }
}