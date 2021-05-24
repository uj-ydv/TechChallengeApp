  #custom-elb-sg
  resource "aws_security_group" "custom-elb-sg" {
  name        = "custom-elb-sg"
  description = "SG for ELB"
  vpc_id      = aws_vpc.customvpc.id

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  tags = {
    Name = "custom-elb-sg"
  }
}

  #custom-instance-sg
  resource "aws_security_group" "custom-instance-sg" {
  name        = "custom-instance-sg"
  description = "SG for instance"
  vpc_id      = aws_vpc.customvpc.id

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks     =   ["0.0.0.0/0"]
  }

  ingress {
    from_port        = 3000
    to_port          = 3000
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks     =   ["0.0.0.0/0"]
  }
  tags = {
    Name = "custom-instance-sg"
  }
}

# Custom DB SG
resource "aws_security_group" "allow-postgres" {
  vpc_id      = aws_vpc.customvpc.id
  name        = "allow-postgres"
  description = "allow-postgres"
  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.custom-instance-sg.id] 
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    self        = true
  }
  tags = {
    Name = "allow-postgres"
  }
}