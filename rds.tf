resource "aws_db_subnet_group" "this" {
  name       = "subnet-group-${random_pet.this.id}"
  subnet_ids = aws_subnet.that.*.id
  tags = merge(local.common_tags,
    {
      "Component" = "RDS",
    }
  )
}

resource "aws_security_group" "those" {
  name   = "allow-rds-traffic-${random_pet.this.id}"
  vpc_id = aws_vpc.this.id

  ingress {
    from_port       = 5432
    protocol        = "tcp"
    to_port         = 5432
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
      "Component" = "RDS",
    }
  )
}

resource "aws_db_instance" "this" {
  engine                 = "postgres"
  engine_version         = "9.6.18"
  instance_class         = "db.t3.medium"
  name                   = "exampledb"
  db_subnet_group_name   = aws_db_subnet_group.this.id
  vpc_security_group_ids = [aws_security_group.those.id]
  skip_final_snapshot    = true
  username               = local.db_creds["db_username"]
  password               = local.db_creds["db_password"]
  allocated_storage      = 10
  ca_cert_identifier     = "rds-ca-2019"
  apply_immediately      = true
  snapshot_identifier    = var.db_snapshot_identifier

  copy_tags_to_snapshot = true
  multi_az              = var.enable_rds_multi_az
  storage_encrypted     = true

  tags = merge(local.common_tags,
    {
      "State"     = "Persistent",
      "Component" = "RDS",
    }
  )

}
