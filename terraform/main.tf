provider "aws" {
  region                   = "eu-west-2"
  shared_credentials_files = ["~/.aws/credentials"]
}
resource "aws_vpc" "p_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "project-vpc"
  }
}
data "aws_availability_zones" "available" {
  state = "available"
}
resource "aws_subnet" "p_subnet" {
  count             = 2
  vpc_id            = aws_vpc.p_vpc.id
  cidr_block        = cidrsubnet(aws_vpc.p_vpc.cidr_block, 8, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name                                                      = "project-subnet"
    /* "kubernetes.io/cluster/project-cluster" = "shared" */
  }
}
resource "aws_internet_gateway" "pigw" {
  vpc_id = aws_vpc.p_vpc.id
}
resource "aws_route_table" "prt" {
  vpc_id = aws_vpc.p_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.pigw.id
  }
  tags = {
    Name = "project-route-table"
  }
}
resource "aws_route_table_association" "rta" {
  count = 1  
  subnet_id      = aws_subnet.p_subnet[count.index].id
  route_table_id = aws_route_table.prt.id
}
resource "aws_security_group" "allow_tcp" {
  name   = "allow-tcp"
  vpc_id = aws_vpc.p_vpc.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
      from_port = 0
      to_port = 0
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "allow_all" {
  name   = "allow-all"
  vpc_id = aws_vpc.p_vpc.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "all"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "all"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "production" {
  count = 1  
  ami                         = "ami-0015a39e4b7c0966f"
  instance_type               = "t3.medium"
  associate_public_ip_address = true
  depends_on                  = [aws_internet_gateway.pigw]
  key_name                    = "devops-project"
  vpc_security_group_ids      = [aws_security_group.allow_tcp.id, aws_security_group.allow_all.id]
  subnet_id                   = aws_subnet.p_subnet[count.index].id
}
/* resource "aws_eks_cluster" "p_cluster" {
  name     = "project-cluster"
  role_arn = "arn:aws:iam::182829305251:role/ClusterManagement"
  vpc_config {
    subnet_ids = aws_subnet.p_subnet[*].id
  }
}
 nresource "aws_eks_node_group" "png" {
  cluster_name    = aws_eks_cluster.p_cluster.name
  node_group_name = "p-nodes"
  node_role_arn   = "arn:aws:iam::182829305251:role/NodeGroup"
  subnet_ids      = aws_subnet.p_subnet[*].id
  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }
} */

