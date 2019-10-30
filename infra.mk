##
# INFRA

.PHONY: exec-ssh
exec-ssh: aws-ec2-get-PrivateIpAddress-1001pharmacies.$(ENV).$(APP)
	$(call exec-ssh,$(AWS_INSTANCE_IP),make exec SERVICE=$(SERVICE) ARGS='\''"$(ARGS)"'\'')
