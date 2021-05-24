# Subnet Group
resource "aws_db_subnet_group" "postgres-subnet" {
  name        = "postgres-subnet"
  description = "RDS subnet group"
  subnet_ids  = [aws_subnet.customvpc-private-1.id, aws_subnet.customvpc-private-2.id]
}

# Parameter Group
resource "aws_db_parameter_group" "postgres-parameters" {
  name        = "postgres-parameters"
  family      = "postgres12"
  description = "PostgresDB parameter group"

}

# Setup RDS Instance
resource "aws_db_instance" "postgres" {
  allocated_storage       = 20 
  engine                  = "postgres"
  instance_class          = "db.t3.micro" 
  identifier              = "postgresdb"
  name                    = "app"
  username                = "postgres"           
  password                = "changeme" 
  db_subnet_group_name    = aws_db_subnet_group.postgres-subnet.name
  parameter_group_name    = aws_db_parameter_group.postgres-parameters.name
  multi_az                = "true" # set to true to have high availability:
  vpc_security_group_ids  = [aws_security_group.allow-postgres.id]
  backup_retention_period = 30                                         
  skip_final_snapshot     = true                                        
  tags = {
    Name = "postgres"
  }
}