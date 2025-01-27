variable "config" {
    type = object({
      name = string
      environment_id = string
        vm = object({
            name = string
            size = optional(string, "Standard_F2")
        }) 
    })
}