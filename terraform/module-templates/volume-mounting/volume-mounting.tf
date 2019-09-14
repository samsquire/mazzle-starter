data "template_file" "volume_mount" {
  template = file("${path.module}/templates/volume_mount.sh")

  vars = {
    mount_point = var.mount_point
    device_name = var.device_name
  }
}

data "template_file" "volume_unmount" {
  template = file("${path.module}/templates/volume_unmount.sh")

  vars = {
    mount_point = var.mount_point
    device_name = var.device_name
  }
}

data "template_file" "volume" {
  template = file("${path.module}/templates/volume.yaml")

  vars = {
    device_name            = var.device_name
    service_content        = base64encode(file("${path.module}/templates/volume.service"))
    volume_mount_content   = base64encode(data.template_file.volume_mount.rendered)
    volume_unmount_content = base64encode(data.template_file.volume_unmount.rendered)
    debmirror_content      = base64encode(file("${path.module}/templates/mirror.sh"))
  }
}

data "template_file" "volume_bootstrap" {
  template = file("${path.module}/templates/volume_bootstrap.sh")
}

output "rendered_cloudconfig" {
  value = data.template_file.volume.rendered
}

output "rendered_volume_bootstrap" {
  value = data.template_file.volume_bootstrap.rendered
}

output "device_name" {
  value = var.device_name
}

resource "aws_iam_policy" "repository" {
  name        = "${var.role}_attach_volume"
  description = "tags, volume mounting"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:DescribeTags",
        "ec2:AttachVolume",
        "ec2:DetachVolume"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF

}

resource "aws_iam_role_policy_attachment" "repository" {
  role       = var.role
  policy_arn = aws_iam_policy.repository.arn
}

