provider "aws" {
  region = "us-east-1"
}

resource "aws_db_instance" "db_microservice1" {
  identifier          = "microservice1-db"
  allocated_storage   = 20
  storage_type        = "gp2"
  engine              = "mysql"
  engine_version      = "8.0"
  instance_class      = "db.t3.micro"
  name                = "microservice1db"
  username            = var.db_username
  password            = var.db_password
  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot = true
}

resource "aws_db_instance" "db_microservice2" {
  identifier          = "microservice2-db"
  allocated_storage   = 20
  storage_type        = "gp2"
  engine              = "mysql"
  engine_version      = "8.0"
  instance_class      = "db.t3.micro"
  name                = "microservice2db"
  username            = var.db_username
  password            = var.db_password
  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot = true
}

variable "db_username" {
  description = "The username for the RDS instance"
  type        = string
}

variable "db_password" {
  description = "The password for the RDS instance"
  type        = string
  sensitive   = true
}
