.PHONY: aws
aws: docker-build-aws
	$(call aws,$(ARGS))

.PHONY: aws-role-create-import-image
aws-role-create-import-image: aws-iam-create-role-$(AWS_VM_IMPORT_ROLE_NAME)  aws-iam-put-role-policy-$(AWS_VM_IMPORT_ROLE_NAME)

.PHONY: aws-iam-create-role-%
aws-iam-create-role-%: docker-build-aws
	$(eval DRYRUN_IGNORE := true)
	$(eval json := $(shell $(call exec,envsubst < aws/policies/$*-trust.json)))
	$(eval DRYRUN_IGNORE := false)
	$(call aws,iam create-role --role-name $* --assume-role-policy-document '$(json)')

.PHONY: aws-iam-put-role-policy-%
aws-iam-put-role-policy-%: docker-build-aws
	$(eval DRYRUN_IGNORE := true)
	$(eval json := $(shell $(call exec,envsubst < aws/policies/$*.json)))
	$(eval DRYRUN_IGNORE := false)
	$(call aws,iam put-role-policy --role-name $* --policy-name $* --policy-document '$(json)')

.PHONY: aws-s3-cp
aws-s3-cp: docker-build-aws
	$(call aws,s3 cp $(PACKER_ISOS) s3://$(AWS_SNAPSHOT_S3_BUCKET))

.PHONY: aws-ec2-import-snapshot
aws-ec2-import-snapshot: docker-build-aws
	$(eval DRYRUN_IGNORE := true)
	$(eval json := $(shell $(call exec,envsubst < aws/import-snapshot.json)))
	$(eval DRYRUN_IGNORE := false)
	$(call aws,ec2 import-snapshot --disk-container '$(json)')

.PHONY: aws-ec2-describe-import-snapshot-tasks
aws-ec2-describe-import-snapshot-tasks: docker-build-aws
	$(call aws,ec2 describe-import-snapshot-tasks)

.PHONY: aws-ec2-register-image
aws-ec2-register-image: docker-build-aws
	$(eval DRYRUN_IGNORE := true)
	$(eval json := $(shell $(call exec,envsubst < aws/register-image.json)))
	$(eval DRYRUN_IGNORE := false)
	$(call aws,ec2 register-image --image-location s3://$(AWS_SNAPSHOT_S3_BUCKET) '$(json)')
