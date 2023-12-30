
variable "rabbitmq_username" {
    description = "Username for RabbitMQ UI"
    type = string
    sensitive = true
}


variable "rabbitmq_password" {
    description = "Password for RabbitMQ UI"
    type = string
    sensitive = true
}

variable "runtime" {
    default = "python3.11"
}