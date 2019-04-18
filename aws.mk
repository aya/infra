IAM_ROLE_NAME ?= vmiport
AWS_SNAPSHOT_S3_BUCKET     ?= production-ftp
AWS_SNAPSHOT_S3_KEY        ?= alpine-3.9.2-x86_64.iso
SNAPSHOT_ISO  ?= iso/alpine-3.9.2-x86_64/alpine-3.9.2-x86_64.iso
ENV_SYSTEM_VARS += AWS_SNAPSHOT_S3_KEY AWS_SNAPSHOT_S3_BUCKET
.PHONY: aws
aws: docker-build-aws
	$(call aws,$(ARGS))

.PHONY: aws-codedeploy
aws-codedeploy:
	$(call aws,deploy create-deployment \
				--application-name $(CODEDEPLOY_APP_NAME) \
		        --deployment-config-name $(CODEDEPLOY_DEPLOYMENT_CONFIG) \
		        --deployment-group-name $(CODEDEPLOY_DEPLOYMENT_GROUP) \
		        --description "$(CODEDEPLOY_DESCRIPTION)" \
		        --github-location repository=$(CODEDEPLOY_GITHUB_REPO)$(comma)commitId=$(CODEDEPLOY_GITHUB_COMMIT_ID))

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
aws-s3-cp: docker-build-aws $(PACKER_ISO_FILE)
	$(eval DRYRUN_IGNORE := true)
	$(if $(call aws,s3 ls s3://$(AWS_S3_BUCKET)/$(AWS_S3_KEY)),$(if $(FORCE),$(eval upload := true),echo 'File s3://$(AWS_S3_BUCKET)/$(AWS_S3_KEY) already exists'),$(eval upload := true))
	$(eval DRYRUN_IGNORE := false)
	$(if $(upload),$(call aws,s3 cp $(PACKER_ISO_FILE) s3://$(AWS_S3_BUCKET)))

.PHONY: aws-ec2-import-snapshot
aws-ec2-import-snapshot: docker-build-aws
	$(eval DRYRUN_IGNORE := true)
	$(eval json := $(shell $(call exec,envsubst < aws/import-snapshot.json)))
	$(eval DRYRUN_IGNORE := false)
	$(eval AWS_TASK_ID := $(shell $(call aws,ec2 import-snapshot --output text --query ImportTaskId --disk-container '$(json)')))
	echo ImportTaskId: $(AWS_TASK_ID)

.PHONY: aws-ec2-describe-import-snapshot-task-%
aws-ec2-describe-import-snapshot-task-%: docker-build-aws
	$(call aws,ec2 describe-import-snapshot-tasks --import-task-ids $*)

.PHONY: aws-ec2-describe-import-snapshot-tasks
aws-ec2-describe-import-snapshot-tasks: docker-build-aws
	$(call aws,ec2 describe-import-snapshot-tasks)

.PHONY: aws-ec2-get-snap-id-import-snapshot-task
aws-ec2-get-snap-id-import-snapshot-task: aws-ec2-get-snap-id-import-snapshot-task-$(AWS_TASK_ID)

.PHONY: aws-ec2-get-snap-id-import-snapshot-task-%
aws-ec2-get-snap-id-import-snapshot-task-%: docker-build-aws
	$(eval AWS_SNAP_ID := $(shell $(call aws,ec2 describe-import-snapshot-tasks --import-task-ids $* --output text --query ImportSnapshotTasks[0].SnapshotTaskDetail.SnapshotId) 2>/dev/null))
	echo SnapshotId: $(AWS_SNAP_ID)

.PHONY: aws-ec2-get-snap-message-import-snapshot-task-%
aws-ec2-get-snap-message-import-snapshot-task-%: docker-build-aws
	$(eval AWS_SNAP_MESSAGE := $(shell $(call aws,ec2 describe-import-snapshot-tasks --import-task-ids $* --output text --query ImportSnapshotTasks[0].SnapshotTaskDetail.StatusMessage) 2>/dev/null))
	echo StatusMessage: $(AWS_SNAP_MESSAGE)

.PHONY: aws-ec2-get-snap-progress-import-snapshot-task-%
aws-ec2-get-snap-progress-import-snapshot-task-%: docker-build-aws
	$(eval AWS_SNAP_PROGRESS := $(shell $(call aws,ec2 describe-import-snapshot-tasks --import-task-ids $* --output text --query ImportSnapshotTasks[0].SnapshotTaskDetail.Progress) 2>/dev/null))
	echo Progress: $(AWS_SNAP_PROGRESS)

.PHONY: aws-ec2-get-snap-size-import-snapshot-task-%
aws-ec2-get-snap-size-import-snapshot-task-%: docker-build-aws
	$(eval AWS_SNAP_SIZE := $(shell $(call aws,ec2 describe-import-snapshot-tasks --import-task-ids $* --output text --query ImportSnapshotTasks[0].SnapshotTaskDetail.DiskImageSize) 2>/dev/null))
	echo DiskImageSize: $(AWS_SNAP_SIZE)

.PHONY: aws-ec2-get-snap-status-import-snapshot-task-%
aws-ec2-get-snap-status-import-snapshot-task-%: docker-build-aws
	$(eval AWS_SNAP_STATUS := $(shell $(call aws,ec2 describe-import-snapshot-tasks --import-task-ids $* --output text --query ImportSnapshotTasks[0].SnapshotTaskDetail.Status) 2>/dev/null))
	echo Status: $(AWS_SNAP_STATUS)

.PHONY: aws-ec2-wait-snap-completed-import-snapshot-task
aws-ec2-wait-snap-completed-import-snapshot-task: aws-ec2-wait-snap-completed-import-snapshot-task-$(AWS_TASK_ID)

.PHONY: aws-ec2-wait-snap-completed-import-snapshot-task-%
aws-ec2-wait-snap-completed-import-snapshot-task-%: docker-build-aws
	while [ `$(call aws,ec2 describe-import-snapshot-tasks --import-task-ids $* --output text --query ImportSnapshotTasks[0].SnapshotTaskDetail.Status)` != "completed$$(printf '\r')" ]; \
	do \
		count=$$(( $${count:-0}+1 )); \
		[ "$${count}" -eq 99 ] && exit 1; \
		sleep 10; \
	done

.PHONY: aws-ec2-wait-snapshot-%
aws-ec2-wait-snapshot-%: docker-build-aws
	$(call aws,ec2 wait snapshot-completed --snapshot-ids $* --output text)

.PHONY: aws-ec2-register-image
aws-ec2-register-image: docker-build-aws aws-ec2-get-snap-id-import-snapshot-task
	$(eval DRYRUN_IGNORE := true)
	$(eval json := $(shell $(call exec,envsubst < aws/register-image-device-mappings.json)))
	$(eval DRYRUN_IGNORE := false)
	$(eval AWS_AMI_ID := $(shell $(call aws,ec2 register-image --name '$(AWS_AMI_NAME)' --description '$(AWS_AMI_DESCRIPTION)' --architecture x86_64 --root-device-name /dev/sda1 --virtualization-type hvm --block-device-mappings '$(json)') 2>/dev/null))
	echo ImageId: $(AWS_AMI_ID)

.PHONY: aws-ami
aws-ami: aws-s3-cp aws-ec2-import-snapshot
	$(call make,aws-ec2-wait-snap-completed-import-snapshot-task,,AWS_TASK_ID)
	$(call make,aws-ec2-register-image,,AWS_TASK_ID)
