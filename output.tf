output "s3name" {
    value = random_string.s3name.result
}

output "websiteendpoint" {
    value = aws_s3_bucket_website_configuration.website.website_endpoint
}
