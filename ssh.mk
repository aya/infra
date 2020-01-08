##
# SSH

.PHONY: ssh
ssh: aws-ec2-get-PrivateIpAddress-$(SERVER_NAME)
	$(call ssh-connect,$(AWS_INSTANCE_IP),$(SHELL))

.PHONY: ssh-connect
ssh-connect: aws-ec2-get-PrivateIpAddress-$(SERVER_NAME)
	$(call ssh-connect,$(AWS_INSTANCE_IP),make connect SERVICE=$(SERVICE))

.PHONY: ssh-exec
ssh-exec: aws-ec2-get-PrivateIpAddress-$(SERVER_NAME)
	$(call ssh-exec,$(AWS_INSTANCE_IP),make exec SERVICE=$(SERVICE) ARGS='\''"$(ARGS)"'\'')
