output "elb_dns_name" {
  value = "${aws_elb.flaconi-elb.dns_name}"
}

output "aws_elb" {
  value = "${aws_elb.flaconi-elb.name}"
}

output "aws_elb_arn" {
  value = "${aws_elb.flaconi-elb.arn}"
}
