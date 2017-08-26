output "public_dns" {
  value = "${aws_instance.data_generator.public_dns}"
}
