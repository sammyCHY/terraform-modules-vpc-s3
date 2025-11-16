resource "aws_vpc" "vpc_id" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
      Name = "vpc_id"
    }
}

resource "aws_Internet_gateway" "aws_igw" {
  
  vpc_id = aws_vpc.vpc_id.id
  tags = {
      Name = "igw_id"
    }

}

# Public Subnets
resource "aws_subnet" "public_subnets" {
  vpc_id      = aws_vpc.vpc_id.id
  cidr_block  = "10.0.0.0/24"
  availability_zone  = "us-east-1"
  map_public_ip_on_launch = true

  tags = {
      Name = "public_subnet"
    }

}


# Private Subnets

resource "aws_subnet" "private_subnets" {
  vpc_id            = aws_vpc.vpc_id.id
  cidr_block        = "10.0.0.0/16"
  availability_zone = "us-east-1"

  tags = {
      Name = "private_subnet"
    }
  
}

# NAT Gateway (Optional)
resource "aws_eip" "nat_eip" {
  count = var.enable_nat_gateway ? 1 : 0

  vpc = true

  tags = merge(
    {
      Name = "${var.project_name}-nat-eip"
    },
    var.tags
  )
}

resource "aws_nat_gateway" "nat" {
  count = var.enable_nat_gateway ? 1 : 0

  allocation_id = aws_eip.nat_eip[0].id
  subnet_id     = values(aws_subnet.public_subnets)[0].id

  tags = merge(
    {
      Name = "${var.project_name}-nat"
    },
    var.tags
  )

  depends_on = [aws_internet_gateway.igw]
}

####################################
# Route Table - Public
####################################
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    {
      Name = "${var.project_name}-public-rt"
    },
    var.tags
  )
}

resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public_rta" {
  for_each = aws_subnet.public_subnets

  route_table_id = aws_route_table.public_rt.id
  subnet_id      = each.value.id
}

####################################
# Route Table - Private
####################################
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    {
      Name = "${var.project_name}-private-rt"
    },
    var.tags
  )
}

resource "aws_route" "private_nat_route" {
  count = var.enable_nat_gateway ? 1 : 0

  route_table_id         = aws_route_table.private_rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat[0].id
}

resource "aws_route_table_association" "private_rta" {
  for_each = aws_subnet.private_subnets

  route_table_id = aws_route_table.private_rt.id
  subnet_id      = each.value.id
}
