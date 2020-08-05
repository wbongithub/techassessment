output "dns" {
  value = aws_lb.this.dns_name
}

output "db" {
  value = aws_db_instance.this.arn
}
