data "template_file" "script" {
  template = file("${path.module}/templates/bootstrap.sh")
}

data "template_cloudinit_config" "config" {
  gzip          = true
  base64_encode = true

  part {
    filename     = "bootstrap.sh"
    content_type = "text/x-shellscript"
    content      = data.template_file.script.rendered
  }
}

resource "aws_instance" "data_generator" {
  ami                    = "ami-4d3a2e29"
  instance_type          = "m4.large"
  iam_instance_profile   = aws_iam_instance_profile.data_generator.id
  key_name               = "vvv-sam-n550jv"
  vpc_security_group_ids = [aws_security_group.data_generator.id]

  user_data = data.template_cloudinit_config.config.rendered

  tags = {
    Name = "${var.vvv_env}-data-generator"
  }
}

