data "aws_ami" "server_ami" {
    most_recent = true
    
    owners = ["099720109477"]
    
    filter {
        name = "name"
        values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
    }
}

resource "random_id" "cg_node_id" {
    byte_length = 2
    count = var.main_instance_count
}

resource "aws_key_pair" "cg_auth" {
    key_name = var.key_name
    public_key = file(var.public_key_path)
}

resource "aws_instance" "cg_main" {
    count = var.main_instance_count
    instance_type = var.main_instance_type
    ami = data.aws_ami.server_ami.id
    key_name = aws_key_pair.cg_auth.id
    vpc_security_group_ids = [aws_security_group.cg_sg.id]
    subnet_id = aws_subnet.cg_public_subnet[count.index].id
    user_data = templatefile("./main-userdata.tpl", {new_hostname = "cg-main-${random_id.cg_node_id[count.index].dec}"})
    root_block_device {
        volume_size = var.main_vol_size
    }
    
    tags = {
        Name = "cg-main-${random_id.cg_node_id[count.index].dec}"
    }
    
    # provisioner "local-exec" {          # will run everytime this resource is created
    #     command = "printf '\n${self.public_ip}' >> aws_hosts"
    # }
    
    # provisioner "local-exec" {
    #     when = destroy
    #     command = "sed -i '/^[0-9]/d' aws_hosts"
    # }
}