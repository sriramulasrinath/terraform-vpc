## create VPC ###
resource "aws_vpc" "main" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"
  enable_dns_hostnames = var.dns-hostname
  tags = merge(
    var.common_tags,
    var.vpc_tags,
    {
    Name = local.resource_name
  }
  )
}

### Create Internet gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  
  tags = merge( 
    var.common_tags,
    var.ig_tags,
    {
    Name = local.resource_name
  }
  )
}
### create public subnet ###
resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidrs)
  availability_zone = local.az_names[count.index]
  map_public_ip_on_launch = true
  vpc_id     = aws_vpc.main.id
  cidr_block = var.public_subnet_cidrs[count.index]

  tags = merge( 
    var.common_tags,
    var.public_subnet_cidrs_tags,
    {
    Name = "${local.resource_name}-Public-${local.az_names[count.index]}"
  }
  )
}
### create private subnet ###
resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidrs)
  availability_zone = local.az_names[count.index]
  vpc_id     = aws_vpc.main.id
  cidr_block = var.private_subnet_cidrs[count.index]

  tags = merge( 
    var.common_tags,
    var.private_subnet_cidrs_tags,
    {
    Name = "${local.resource_name}-Private-${local.az_names[count.index]}"
  }
  )
}
### create Database subnet ###
resource "aws_subnet" "Database" {
  count = length(var.Database_subnet_cidrs)
  availability_zone = local.az_names[count.index]
  vpc_id     = aws_vpc.main.id
  cidr_block = var.Database_subnet_cidrs[count.index]

  tags = merge( 
    var.common_tags,
    var.Database_subnet_cidrs_tags,
    {
    Name = "${local.resource_name}-database-${local.az_names[count.index]}"
  }
  )
}

resource "aws_db_subnet_group" "default" {
  name       = "${local.resource_name}"
  subnet_ids = aws_subnet.Database[*].id

  tags = merge(
    var.common_tags,
    var.database_subnet_group_tags,
    {
        Name = "${local.resource_name}"
    }
  )
}

### NAT Gateway
resource "aws_eip" "nat" { #attaching elastic ip 
  domain   = "vpc"
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id #only for us-east-1 region

  tags = merge( 
    var.common_tags,
    var.nat_gatewat_tags,
    {
    Name = "${local.resource_name}" #expense-dev --> which is project_name
  }
  )

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.gw]
}

###Public-Route Table####
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = merge( 
    var.common_tags,
    var.public_route_table_tags,
    {
    Name = "${local.resource_name}-Public" #expense-dev --> which is project_name
  }
  )
}

###Private-Route Table####
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  
  tags = merge( 
    var.common_tags,
    var.private_route_table_tags,
    {
    Name = "${local.resource_name}-Private" #expense-dev --> which is project_name
  }
  )
}

###Databse-Route Table####
resource "aws_route_table" "Database" {
  vpc_id = aws_vpc.main.id
  
  tags = merge( 
    var.common_tags,
    var.Database_route_table_tags,
    {
    Name = "${local.resource_name}-database" #expense-dev --> which is project_name
  }
  )
}
##attaching pulic route to internetgateway###
resource "aws_route" "public_route" {
  route_table_id = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.gw.id
}

##attaching private route to natgateway###
resource "aws_route" "private_route" {
  route_table_id = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.nat.id
}
##attaching database route to natgateway###
resource "aws_route" "Database_route" {
  route_table_id = aws_route_table.Database.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.nat.id
}

###Route table and subnet association###
resource "aws_route_table_association" "public" {
  count = length(var.public_subnet_cidrs)
  subnet_id      = element(aws_subnet.public[*].id, count.index)
  route_table_id = aws_route_table.public.id
}
resource "aws_route_table_association" "private" {
  count = length(var.private_subnet_cidrs)
  subnet_id      = element(aws_subnet.private[*].id, count.index)
  route_table_id = aws_route_table.private.id
}
resource "aws_route_table_association" "Database" {
  count = length(var.Database_subnet_cidrs)
  subnet_id      = element(aws_subnet.Database[*].id, count.index)
  route_table_id = aws_route_table.Database.id
}