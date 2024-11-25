output "instance_ssh_access" {
  description = "Command to ingress to the VM"
  value = join("", ["ssh -i ${aws_instance.jenkins-agent.key_name} ubuntu@", aws_instance.jenkins-agent.public_ip])
}

output "instance-ip" {
  value = aws_instance.jenkins-agent.public_ip
}