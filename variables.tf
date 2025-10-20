variable "region" {
    type = string
    default = "us-east-1" 
}
variable "project" { 
    type = string
    default = "serverlessapp" 
}
variable "env"  { 
    type = string
    default = "dev" 
}
variable "allowed_origin" { 
    type = string
    default = "*" 
} 