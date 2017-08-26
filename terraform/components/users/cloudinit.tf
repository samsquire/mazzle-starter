data "template_file" "users" {
  template = "${file("${path.module}/templates/cloudinit.yml")}"
  vars {}
}

output "users" {
  value = "${data.template_file.users.rendered}"
}


