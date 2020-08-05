resource "aws_elasticache_cluster" "this" {
  cluster_id           = "elasticache-cluster-${random_pet.this.id}"
  engine               = "memcached"
  node_type            = "cache.t2.micro"
  num_cache_nodes      = 1
  parameter_group_name = "default.memcached1.5"
  port                 = 11211
  tags = merge(local.common_tags,
    {
      "Component" = "ElastiCache",
    }
  )
}

resource "aws_security_group" "that" {
  name   = "allow-elasticache-traffic"
  vpc_id = aws_vpc.this.id

  ingress {
    from_port       = 11211
    protocol        = "tcp"
    to_port         = 11211
    security_groups = [aws_security_group.this.id]
  }

  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge(local.common_tags,
    {
      "Component" = "ElastiCache",
    }
  )
}

resource "aws_elasticache_subnet_group" "this" {
  name       = "elasticache-subnet-group-${random_pet.this.id}"
  subnet_ids = aws_subnet.that.*.id

}
