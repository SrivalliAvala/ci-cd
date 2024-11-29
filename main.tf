module "jenkins" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  
  ami = data.aws_ami.ami_info.id
  name = "jenkins"
  user_data = file("jenkins.sh")

  instance_type          = "t3.micro"
  vpc_security_group_ids = ["sg-0372233cbe1615ef2"]
  subnet_id              = ["subnet-0077a5c7214ba9a8d"]

  tags = merge(
    {
        Name = jenkins
    }
  )
  root_block_device = [
    {
      volume_size = 50       # Size of the root volume in GB
      volume_type = "gp3"    # General Purpose SSD (you can change it if needed)
      delete_on_termination = true  # Automatically delete the volume when the instance is terminated
    }
  ]

}


module "jenkins-agent" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  
  ami = data.aws_ami.ami_info.id
  name = "jenkins"
  user_data = file("jenkins-agent.sh")

  instance_type          = "t3.micro"
  vpc_security_group_ids = ["sg-0372233cbe1615ef2"]
  subnet_id              = ["subnet-0077a5c7214ba9a8d"]

  tags = merge(
    {
        Name = jenkins-agent
    }
  )
  root_block_device = [
    {
      volume_size = 50       # Size of the root volume in GB
      volume_type = "gp3"    # General Purpose SSD (you can change it if needed)
      delete_on_termination = true  # Automatically delete the volume when the instance is terminated
    }
  ]

}

module "records" {
  source  = "terraform-aws-modules/route53/aws//modules/records"
  version = "~> 2.0"

  zone_name = var.zone_name

  records = [
    {
      name    = "jenkins"
      type    = "A"
      ttl     = 1
      records = [
        module.jenkins.public_ip
      ]
      allow_overwrite = true
    },
    {
      name    = "jenkins-agent"
      type    = "A"
      ttl     = 1
      records = [
        module.jenkins-agent.public_ip
      ]
      allow_overwrite = true

    }
  ]
}