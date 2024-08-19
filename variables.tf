variable "cidr_block" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnets" {
  description = "Public subnets for VPC"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24"]
}

variable "private_subnets" {
  description = "Private subnets for VPC"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "ecs_task_execution_role_name" {
  description = "IAM role for ECS tasks execution"
  type        = string
  default     = "ecsTaskExecutionRole"
}

variable "cluster_name" {
  description = "ECS cluster name"
  type        = string
  default     = "my-cluster"
}

variable "task_family" {
  description = "ECS task family name"
  type        = string
  default     = "my-app"
}

variable "container_image" {
  description = "ECS container image"
  type        = string
  default     = "abtagir/ecs-app:version1"
}

variable "alb_name" {
  description = "ALB name"
  type        = string
  default     = "app-lb"
}

variable "availability_zones" {
  description = "AZ to use"
  type        = list(string)
  default     = ["us-west-2a", "us-west-2b"]
}
