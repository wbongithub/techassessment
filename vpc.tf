locals {
  public_subnets = {
    "${var.region}a" = "172.16.0.0/21"
    "${var.region}b" = "172.16.8.0/21"
    "${var.region}c" = "172.16.16.0/21"
  }
  private_subnets = {
    "${var.region}a" = "172.16.24.0/21"
    "${var.region}b" = "172.16.32.0/21"
    "${var.region}c" = "172.16.40.0/21"
  }
}

resource "aws_vpc" "this" {
  cidr_block = "172.16.0.0/16"

  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = merge(local.common_tags,
    {
      "Component" = "Network",
    }
  )
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(local.common_tags,
    {
      "Component" = "Network",
    }
  )
}

resource "aws_eip" "nat" {
  vpc  = true
  tags = merge(local.common_tags, {})
}

resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.this.*.id[0]
  tags = merge(local.common_tags,
    {
      "Component" = "Network",
    }
  )
}

resource "aws_subnet" "this" {
  count      = length(local.public_subnets)
  cidr_block = element(values(local.public_subnets), count.index)
  vpc_id     = aws_vpc.this.id

  map_public_ip_on_launch = true
  availability_zone       = element(keys(local.public_subnets), count.index)

  tags = merge(local.common_tags,
    {
      "AZ"        = element(keys(local.public_subnets), count.index),
      "Component" = "Network",
    }
  )
}

resource "aws_route_table" "this" {
  vpc_id = aws_vpc.this.id
  tags = merge(local.common_tags,
    {
      "Component" = "Network",
    }
  )
}

resource "aws_route" "this" {
  route_table_id         = aws_route_table.this.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_route_table_association" "this" {
  count          = length(local.public_subnets)
  route_table_id = aws_route_table.this.id
  subnet_id      = element(aws_subnet.this.*.id, count.index)
}

resource "aws_subnet" "that" {
  count      = length(local.private_subnets)
  cidr_block = element(values(local.private_subnets), count.index)
  vpc_id     = aws_vpc.this.id

  map_public_ip_on_launch = false
  availability_zone       = element(keys(local.private_subnets), count.index)

  tags = merge(local.common_tags,
    {
      "AZ"        = element(keys(local.private_subnets), count.index),
      "Component" = "Network",
    }
  )
}

resource "aws_route_table" "that" {
  vpc_id = aws_vpc.this.id
  tags = merge(local.common_tags,
    {
      "Component" = "Network",
    }
  )
}

resource "aws_route" "that" {
  route_table_id         = aws_route_table.that.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this.id
}

resource "aws_route_table_association" "that" {
  count          = length(local.private_subnets)
  route_table_id = aws_route_table.that.id
  subnet_id      = element(aws_subnet.that.*.id, count.index)
}

