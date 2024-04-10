#create a VCP
resource "aws_vpc" "my_vpc" {
  cidr_block       = var.cidr
  instance_tenancy = "default"

  tags = {
    Name = "main"
  }
}

#create subnet
resource "aws_subnet" "public_subnet1" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "public_subnet2" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-south-1b"
  map_public_ip_on_launch = true
}

#create IGW
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.my_vpc.id
}

#create route table
resource "aws_route_table" "rtable" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}


#associate subet to route table
resource "aws_route_table_association" "rtable_association1" {
  subnet_id      = aws_subnet.public_subnet1.id
  route_table_id = aws_route_table.rtable.id
}

resource "aws_route_table_association" "rtable_association2" {
  subnet_id      = aws_subnet.public_subnet2.id
  route_table_id = aws_route_table.rtable.id
}


#create security groups
resource "aws_security_group" "mysg" {
  name   = "mysg"
  vpc_id = aws_vpc.my_vpc.id

  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks  = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks  = ["0.0.0.0/0"]
  }

  egress {
    from_port  = 0
    to_port    = 0
    protocol   = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#create an S3 bucket
resource "aws_s3_bucket" "mys3bucket" {
  bucket = var.bucketname
}

resource "aws_s3_bucket_ownership_controls" "mybucketowner" {
  bucket = aws_s3_bucket.mys3bucket.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

#To enable ACL for public
resource "aws_s3_bucket_public_access_block" "mybucketaccess" {
  bucket = aws_s3_bucket.mys3bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}


resource "aws_s3_bucket_acl" "mybucketacl" {
  depends_on = [
    aws_s3_bucket_ownership_controls.mybucketowner,
    aws_s3_bucket_public_access_block.mybucketaccess,
  ]

  bucket = aws_s3_bucket.mys3bucket.id
  acl    = "public-read"
}


#create instances in VPC
resource "aws_instance" "webserver1" {
  instance_type          = "t2.micro"
  ami                    = "ami-007020fd9c84e18c7"
  vpc_security_group_ids = [aws_security_group.mysg.id]
  subnet_id              = aws_subnet.public_subnet1.id
  user_data              = "src/userdata.sh"
}

resource "aws_instance" "webserver2" {
  instance_type          = "t2.micro"
  ami                    = "ami-007020fd9c84e18c7"
  vpc_security_group_ids = [aws_security_group.mysg.id]
  subnet_id              = aws_subnet.public_subnet2.id
  user_data              = "src/userdata1.sh"
}

#create a application LB
resource "aws_lb" "alb" {
  name               = "myalb"
  internal           = false
  load_balancer_type = "application"
  security_groups     = [aws_security_group.mysg.id]
  subnets             = [aws_subnet.public_subnet1.id, aws_subnet.public_subnet2.id]

  tags = {
    Name = "web"
  }
}


#create target group
resource "aws_lb_target_group" "alb-tg" {
  name     = "myTG"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.my_vpc.id

  health_check {
    path = "/"
    port = "traffic-port"
  }
}

resource "aws_lb_target_group_attachment" "attach1" {
  target_group_arn = aws_lb_target_group.alb-tg.id
  target_id     = aws_instance.webserver1.id
  port           = 80
}

resource "aws_lb_target_group_attachment" "attach2" {
  target_group_arn = aws_lb_target_group.alb-tg.id
  target_id     = aws_instance.webserver2.id
  port           = 80
}

#add listener
resource "aws_lb_listener" "listerner" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.alb-tg.arn
    type             = "forward"
  }
}