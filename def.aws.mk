AWS_AMI_DESCRIPTION             ?= Created from $(AWS_SNAP_ID) by $(USER) at $(shell date +%Y%m%d\ %H:%M:%S\ %Z)
AWS_AMI_NAME                    ?= $(ENV)-$(APP)-ami-$(PACKER_ISO_NAME)-$(VERSION)
AWS_DEFAULT_REGION              ?= eu-west-1
AWS_DEFAULT_OUTPUT              ?= text
AWS_PROFILE                     ?= default
AWS_VM_IMPORT_ROLE_NAME         ?= vmimport
AWS_S3_BUCKET                   ?= enova-aws-config
AWS_S3_KEY                      ?= $(PACKER_ISO_NAME).iso
AWS_SNAP_DESCRIPTION            ?= Created from s3://$(AWS_S3_BUCKET)/$(AWS_S3_KEY) by $(USER) at $(shell date +%Y%m%d\ %H:%M:%S\ %Z)
AWS_SNAP_NAME                   ?= $(ENV)-$(APP)-snap-$(PACKER_ISO_NAME)-$(VERSION)
CMDS                            += aws
ENV_SYSTEM_VARS                 += AWS_AMI_DESCRIPTION AWS_AMI_NAME AWS_SNAP_DESCRIPTION AWS_SNAP_NAME AWS_S3_BUCKET AWS_S3_KEY AWS_SNAP_ID

ifeq ($(DOCKER), true)
define aws
	$(call run,$(DOCKER_SSH_AUTH) -v $$HOME/.aws:/root/.aws:ro anigeo/awscli:latest $(1))
endef
else
define aws
	$(call run,aws $(1))
endef
endif
