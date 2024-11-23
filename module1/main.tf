terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

# Create a VPC
resource "aws_vpc" "Terra_Vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "Terra_Vpc"
  }
}

resource "aws_subnet" "Terra_PSN1" {
  vpc_id     = aws_vpc.Terra_Vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "Terra_PSN1"
  }
}

resource "aws_subnet" "Terra_PSN2" {
  vpc_id     = aws_vpc.Terra_Vpc.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "Terra_PSN2"
  }
}

resource "aws_subnet" "Terra_PvSN1" {
  vpc_id     = aws_vpc.Terra_Vpc.id
  cidr_block = "10.0.3.0/24"

  tags = {
    Name = "Terra_PvSN1"
  }
}

resource "aws_subnet" "Terra_PvSN2" {
  vpc_id     = aws_vpc.Terra_Vpc.id
  cidr_block = "10.0.4.0/24"

  tags = {
    Name = "Terra_PvSN2"
  }
}

resource "aws_internet_gateway" "Terra_Igw" {
  vpc_id = aws_vpc.Terra_Vpc.id

  tags = {
    Name = "Terra_Igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.Terra_Vpc.id

  tags = {
    Name = "public"
  }

}

resource "aws_route" "public_route" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.Terra_Igw.id


}

resource "aws_route_table_association" "public_subnet_1" {
  subnet_id      = aws_subnet.Terra_PSN1.id
  route_table_id = aws_route_table.public.id

}
resource "aws_route_table_association" "public_subnet_2" {
  subnet_id      = aws_subnet.Terra_PSN2.id
  route_table_id = aws_route_table.public.id
}

resource "aws_eip" "Terra_Nat_Eip" {
  tags = {
    Name = "Terra_Nat_Eip"
  }
}

resource "aws_nat_gateway" "Terra_Ngw" {
  allocation_id = aws_eip.Terra_Nat_Eip.id
  subnet_id     = aws_subnet.Terra_PSN1.id

  tags = {
    Name = "Terra_Ngw"
  }
}


resource "aws_route_table" "private" {
  vpc_id = aws_vpc.Terra_Vpc.id

  tags = {
    Name = "private"
  }
}

resource "aws_route" "private_route" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.Terra_Ngw.id

}

resource "aws_route_table_association" "private_subnet_1" {
  subnet_id      = aws_subnet.Terra_PvSN1.id
  route_table_id = aws_route_table.private.id
}
resource "aws_route_table_association" "private_subnet_2" {
  subnet_id      = aws_subnet.Terra_PvSN2.id
  route_table_id = aws_route_table.private.id
}

