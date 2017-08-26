resource "aws_iam_user" "sam" {
  name = "sam"
}


resource "aws_iam_group" "admins" {
  name = "administrators"
}

resource "aws_iam_group_membership" "admins" {
  name = "admins"
  users = ["${aws_iam_user.sam.name}"]
  group = "${aws_iam_group.admins.name}"
}

resource "aws_iam_group_policy_attachment" "admins_access" {
  group = "${aws_iam_group.admins.name}"
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_access_key" "sam" {
  user = "${aws_iam_user.sam.name}"
  pgp_key = "${base64encode(file("${path.module}/keys/sam.pub"))}"
}

output "sam_access_key" {
  value = "${aws_iam_access_key.sam.id}"
}

output "sam_secret_key" {
  value = "${aws_iam_access_key.sam.encrypted_secret}"
}

