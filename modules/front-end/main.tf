#### S3 website ##### 
resource "aws_s3_bucket" "souher_cloud_resume_site" {
  bucket = var.bucket-name #Name will be given at runtime
  acl    = "public-read"
  policy = file("${path.module}/policy.json")

  #Convert bucket into a static website
  website {
    index_document = "index.html"
    error_document = "404.html"
  }
}

#Upload files into the bucket
resource "aws_s3_bucket_object" "loop_to_upload_multiple_html_files" {
for_each = fileset("${path.module}/html/", "*.html")
bucket = aws_s3_bucket.souher_cloud_resume_site.id
key = each.value #Name of object in the bucket
source = "${path.module}/html/${each.value}" #Path to file
content_type = "text/html"
etag = filemd5("${path.module}/html/${each.value}") #Creates and checks hash of local file vs remote. If there are any changes to local file, the hash will be different. Upload new changes at the next apply.
}

#Upload files into the bucket
resource "aws_s3_bucket_object" "loop_to_upload_multiple_css_files" {
for_each = fileset("${path.module}/html/", "*.css")
bucket = aws_s3_bucket.souher_cloud_resume_site.id
key = each.value #Name of object in the bucket
source = "${path.module}/html/${each.value}" #Path to file
content_type = "text/css"
etag = filemd5("${path.module}/html/${each.value}") #Creates and checks hash of local file vs remote. If there are any changes to local file, the hash will be different. Upload new changes at the next apply.
}

#Upload files into the bucket
resource "aws_s3_bucket_object" "loop_to_upload_multiple_png_files" {
for_each = fileset("${path.module}/html/", "*.png")
bucket = aws_s3_bucket.souher_cloud_resume_site.id
key = each.value #Name of object in the bucket
source = "${path.module}/html/${each.value}" #Path to file
content_type = "image/png"
etag = filemd5("${path.module}/html/${each.value}") #Creates and checks hash of local file vs remote. If there are any changes to local file, the hash will be different. Upload new changes at the next apply.
}


#Upload files into the bucket
resource "aws_s3_bucket_object" "loop_to_upload_multiple_js_files" {
for_each = fileset("${path.module}/html/", "*.js")
bucket = aws_s3_bucket.souher_cloud_resume_site.id
key = each.value #Name of object in the bucket
source = "${path.module}/html/${each.value}" #Path to file
content_type = "text/js"
etag = filemd5("${path.module}/html/${each.value}") #Creates and checks hash of local file vs remote. If there are any changes to local file, the hash will be different. Upload new changes at the next apply.
}

##### Cloudfront distribution ####

resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = aws_s3_bucket.souher_cloud_resume_site.website_endpoint
    origin_id   = var.cloudfront-origin-id

    #https://docs.aws.amazon.com/cloudfront/latest/APIReference/API_CustomOriginConfig.html
    custom_origin_config {
      http_port = 80
      https_port = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }
  
  }

  enabled             = true #Accept end user request for content
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  aliases = [var.domain-name]

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = var.cloudfront-origin-id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 0
  }

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate_validation.cert.certificate_arn
    ssl_support_method = "sni-only"
    minimum_protocol_version = "TLSv1"
  }
}

#### Route53 ####

resource "aws_route53_zone" "main" {
  name = var.domain-name
}

# data "aws_route53_zone" "public" {
#   name         = var.domain-name
#   private_zone = false
# }

resource "aws_route53_record" "domain" {
  zone_id = aws_route53_zone.main.zone_id
  name    = aws_route53_zone.main.name
  type    = "A"
  alias {
    name = aws_cloudfront_distribution.s3_distribution.domain_name
    zone_id = aws_cloudfront_distribution.s3_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}

/*
resource "aws_route53_record" "www-domain" {
zone_id = aws_route53_zone.main.zone_id
name    = "www.${var.domain-name}"
type    = "A"
alias {
  name = aws_cloudfront_distribution.s3_distribution.domain_name
  zone_id = aws_cloudfront_distribution.s3_distribution.hosted_zone_id
  evaluate_target_health = false
}}*/


#### ACM ####
# SSL Certificate
#Provider to create acm in us-east-1
provider "aws" {
  alias = "us-east-1"
  region = "us-east-1"
}

resource "aws_acm_certificate" "ssl" {
  provider = aws.us-east-1
  domain_name = var.domain-name
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "domain_validation" {
  for_each = {
    for dvo in aws_acm_certificate.ssl.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.main.zone_id
}

resource "aws_acm_certificate_validation" "cert" {
  provider = aws.us-east-1
  certificate_arn = aws_acm_certificate.ssl.arn
  validation_record_fqdns = [for record in aws_route53_record.domain_validation : record.fqdn]
}










