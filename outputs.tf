#Outputs to display after a succesful provisioning of resources, or when using the terraform output command

output "instance_ssh_access" {
  description = "Command to access the VM"
  value       = join("", ["ssh -i ${aws_instance.jenkins-agent.key_name} ubuntu@", aws_instance.jenkins-agent.public_ip])
}

output "instance-ip" {
  description = "Instance's IP"
  value       = aws_instance.jenkins-agent.public_ip
}