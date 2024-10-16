terraform { 
  cloud { 
    
    organization = "cloud-leomontt" 

    workspaces { 
      name = "sagemaker" 
    } 
  } 
}
