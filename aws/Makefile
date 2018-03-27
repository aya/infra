include ../env.mk
AWS_ENV=
ifeq ($(DEBUG), true)
	AWS_ARGS+= --debug
endif
ifeq ($(ENV), dev)
	AWS_ENV=
endif
ifeq ($(DOCKER), true)
	AWS_ENV:=$(patsubst %,-e %,$(AWS_ENV))
endif

CMDS := aws
include ../def.mk
include ../help.mk

.PHONY: help aws

all: build

aws: 
	$(call aws,$(ARGS))

docker-build: ## Build docker image
	$(MAKE) --directory=.. docker-build DOCKERS=docker/aws

policy: policy-role policy-trust

policy-trust: 
	$(call aws, iam create-role --role-name vmimport --assume-role-policy-document file://policy/trust.json)

policy-role:
	$(call aws, iam put-role-policy --role-name vmimport --policy-name vmimport --policy-document file://policy/role.json)

snapshot-upload:
	$(call aws, s3 cp packer/iso/alpine-meup-3.6.2-x86_64.iso s3://$(AWS_S3_BUCKET))

snapshot-import:
	$(call aws, import-snapshot --disk-container file://snapshot.json)

build: docker-build ## Build iso images
