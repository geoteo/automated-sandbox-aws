aws ec2 describe-instances --query 'Reservations[*].Instances[*].[PublicIpAddress, Tags[0].Value]' --filters "Name=instance-state-name,Values=running"