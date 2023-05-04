variable "subnet_id" {}
variable "sg_id"  {}
variable "ami_id" {}
variable "key_name" {}
variable "cluster_name" {}
variable "instance_type" {}
variable "autoscaling_group_name" {}
variable "lauch_template_name" {}
variable "autoscaling_policy_name" {}
variable max_size { type = number }
variable min_size{ type = number }
variable desired_capacity { type = number }
variable "name" {} 