variable "service_name" {
    type = string
    description = "Generic service name"
    default = "edazhackathon"
}

variable "app_locations" {
    type = map
    description = "Configuration map for each app deployment"
    default = {
        westeurope = {
        },
        eastus = {
        }
    }   
}