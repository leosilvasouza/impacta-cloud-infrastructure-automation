terraform { 
  cloud { 
    
    organization = "cloud-leomontt" 

    workspaces { 
      name = "impacta" 
    } 
  } 
}
