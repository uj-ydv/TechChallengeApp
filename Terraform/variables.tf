variable "AWS_ACCESS_KEY" {}
variable "AWS_SECRET_KEY" {}
variable "AWS_REGION" {
    default = "ap-southeast-2"
}

variable "PATH_TO_PRIVATE_KEY"{
    default = "servianKeyPair"
}

variable "PATH_TO_PUBLIC_KEY" {
    default = "servianKeyPair.pub"
}

variable "INSTANCE_USERNAME" {
    default = "ubuntu"
}