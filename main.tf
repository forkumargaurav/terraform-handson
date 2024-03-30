resource "random_string" "s3name" {
  length           = 16
  special          = true
  override_special = "-"
  upper   = false
  lower = true
}

#create S3 bucket
resource "aws_s3_bucket" "mybucket" {
  bucket = "myterraform-zeaxl0si8p7s6zmi"
}

resource "aws_s3_bucket_ownership_controls" "ownershiprule" {
  bucket = aws_s3_bucket.mybucket.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# To enable ACL for public read
resource "aws_s3_bucket_public_access_block" "mybucketaccess" {
  bucket = aws_s3_bucket.mybucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "mybucketacl" {
  depends_on = [
    aws_s3_bucket_ownership_controls.ownershiprule,
    aws_s3_bucket_public_access_block.mybucketaccess,
  ]

  bucket = aws_s3_bucket.mybucket.id
  acl    = "public-read"
}

#To add file in S# for static website
resource "aws_s3_bucket_object" "index" {
  bucket = aws_s3_bucket.mybucket.id
  key    = "index.html"
  source = "src/index.html"  # Provide the path to your index.html file
  acl    = "public-read"
  content_type = "text.html"
  depends_on = [aws_s3_bucket_acl.mybucketacl]
}

resource "aws_s3_bucket_object" "error" {
  bucket = aws_s3_bucket.mybucket.id
  key    = "error.html"
  source = "src/error.html"  # Provide the path to your error.html file
  acl    = "public-read"
  content_type = "text.html"
  depends_on = [aws_s3_bucket_acl.mybucketacl]
}

resource "aws_s3_bucket_object" "pic" {
  bucket = aws_s3_bucket.mybucket.id
  key    = "pic.jpg"
  source = "src/pic.jpg"   # Provide the path to your image file
  acl    = "public-read"
  depends_on = [aws_s3_bucket_acl.mybucketacl]
}

#To enable Static website in S3
resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.mybucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }

  depends_on = [aws_s3_bucket_acl.mybucketacl]
}