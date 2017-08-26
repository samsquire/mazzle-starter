resource "aws_iam_role" "data_generator" {
  name = "data-generator"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "data_generator" {
  name = "data_generator"
  role = "${aws_iam_role.data_generator.name}"
}

data "aws_iam_policy_document" "see_content_bucket" {
  statement {
    sid = "1"

    actions = [
      "s3:ListAllMyBuckets",
      "s3:GetBucketLocation",
    ]

    resources = [
      "arn:aws:s3:::*",
    ]
  }

  statement {
    actions = [
      "s3:ListBucket",
      "s3:HeadObject",
      "s3:GetObject",
      "s3:PutObject",
    ]

    resources = [
      "arn:aws:s3:::vvv-${var.vvv_env}-content/*",
    ]
  }

  statement {
    actions = [
      "s3:*",
    ]

    resources = [
      "arn:aws:s3:::vvv-${var.vvv_env}-content",
    ]
  }
}

resource "aws_iam_policy" "content_policy" {
  name   = "${var.vvv_env}_content_policy"
  path   = "/"
  policy = "${data.aws_iam_policy_document.see_content_bucket.json}"
}

resource "aws_iam_role_policy_attachment" "data_generator_s3" {
  role       = "${aws_iam_role.data_generator.name}"
  policy_arn = "${aws_iam_policy.content_policy.arn}"
}
