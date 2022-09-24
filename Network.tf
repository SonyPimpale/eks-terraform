
// VPC
resource "aws_vpc" "vpc" {
  cidr_block           = var.VPC_CIDR
  enable_dns_hostnames = true

  tags = {
    Name = "${var.environment}-vpc"
  }
}


// Public Subnet
resource "aws_subnet" "public-subnet" {
  vpc_id                  = aws_vpc.vpc.id
  count                   = length(var.PUB_CIDR)
  cidr_block              = element(var.PUB_CIDR, count.index)
  availability_zone       = element(var.AZ, count.index)

  map_public_ip_on_launch = true

  tags = {
    Name = "${var.environment}-${element(var.AZ,count.index)}-public-subnet"
  }
}


// Private Subnet
resource "aws_subnet" "private-subnet" {
  vpc_id                  = aws_vpc.vpc.id
  count                   = length(var.PRIV_CIDR)
  cidr_block              = element(var.PRIV_CIDR, count.index)
  availability_zone       = element(var.AZ, count.index)

  map_public_ip_on_launch = false

  tags = {
    Name = "${var.environment}-${element(var.AZ,count.index)}-private-subnet"
  }
}


// IGW
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.environment}-igw"
  }
}


// NAT GW
resource "aws_eip" "natip" {
  vpc        = true
  depends_on = [aws_internet_gateway.igw]

  tags = {
    Name = "${var.environment}-natip"
  }
}

resource "aws_nat_gateway" "natgw" {
  allocation_id = aws_eip.natip.id
  subnet_id     = element(aws_subnet.public-subnet.*.id, 0)

  tags = {
    Name = "${var.environment}-natgw"
  }

  depends_on = [aws_internet_gateway.igw]
}


// Route Table - public subnet
resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.environment}-public-rt"
  }
}


// Route Table - private subnet
resource "aws_route_table" "private-rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.natgw.id
  }

  tags = {
    Name = "${var.environment}-private-rt"
  }
}


// Route Table Association - public subnet
resource "aws_route_table_association" "public-rta" {
  count          = length(var.PUB_CIDR)
  subnet_id      = element(aws_subnet.public-subnet.*.id, count.index)
  route_table_id = aws_route_table.public-rt.id
}


// Route Table Association - private subnet
resource "aws_route_table_association" "private-rta" {
  count          = length(var.PRIV_CIDR)
  subnet_id      = element(aws_subnet.private-subnet.*.id, count.index)
  route_table_id = aws_route_table.private-rt.id
}


// Security Group
resource "aws_security_group" "sg" {
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "Allow HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment}-sg"
  }
}
