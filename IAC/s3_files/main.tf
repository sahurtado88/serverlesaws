##### Creating a Random String #####
resource "random_string" "random" {
  length  = 6
  special = false
  upper   = false
}

##### Creating an S3 Bucket #####
resource "aws_s3_bucket" "bucket" {
  bucket        = "sahurtad-hkdgia"
  force_destroy = true
}

resource "aws_s3_bucket_website_configuration" "blog" {
  bucket = aws_s3_bucket.bucket.id
  index_document {
    suffix = "index.html"
  }
  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_public_access_block" "public_access_block" {
  bucket                  = aws_s3_bucket.bucket.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.bucket.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "arn:aws:s3:::${aws_s3_bucket.bucket.id}/*"
      },
    ]
  })
}

##### will upload all the files present under HTML folder to the S3 bucket #####
resource "aws_s3_object" "upload_object" {
  for_each     = fileset("html/", "**")
  bucket       = aws_s3_bucket.bucket.id
  key          = each.value
  source       = "html/${each.value}"
  etag         = filemd5("html/${each.value}")
  content_type = "text/html"
}

## Lambda role

resource "aws_iam_role" "lambda_role" {
  name               = "Lambda_Function_Role"
  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "lambda.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF
}

### iam policy

resource "aws_iam_policy" "iam_policy_for_lambda" {

  name        = "aws_iam_policy_for_terraform_aws_lambda_role"
  path        = "/"
  description = "AWS IAM Policy for managing aws lambda role"
  policy      = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": [
       "logs:CreateLogGroup",
       "logs:CreateLogStream",
       "logs:PutLogEvents"
     ],
     "Resource": "arn:aws:logs:*:*:*",
     "Effect": "Allow"
   },
   {
     "Action": [
       "s3:GetObject"
     ],
     "Resource": "arn:aws:s3:::${aws_s3_bucket.bucket.id}/*",
     "Effect": "Allow"
   }
 ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role = aws_iam_role.lambda_role.name
}

## attach policy to role
resource "aws_iam_role_policy_attachment" "attach_iam_policy_to_iam_role" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.iam_policy_for_lambda.arn
}

# generates an archive from content, a file or a directory of files
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda/"
  output_path = "${path.module}/lambda/Chat-Proxy.zip"
}

resource "aws_lambda_function" "lambda_func" {
  filename      = data.archive_file.lambda_zip.output_path
  function_name = "Chat-Proxy"
  role          = aws_iam_role.lambda_role.arn
  handler       = "Chat-Proxy.handler"
  runtime       = "nodejs22.x"
}

