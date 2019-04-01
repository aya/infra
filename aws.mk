.PHONY: aws
aws:
	$(call aws,$(ARGS))

.PHONY: policy
policy: policy-role policy-trust

.PHONY: policy-trust
policy-trust:
	$(call aws,iam create-role --role-name vmimport --assume-role-policy-document file://policy/trust.json)

.PHONY: policy-role
policy-role:
	$(call aws,iam put-role-policy --role-name vmimport --policy-name vmimport --policy-document file://policy/role.json)

.PHONY: snapshot-upload
snapshot-upload:
	$(call aws,s3 cp ../packer/iso/alpine-3.7.0-x86_64.iso s3://$(AWS_S3_BUCKET))

.PHONY: snapshot-import
snapshot-import:
	$(call aws,import-snapshot --disk-container file://snapshot.json)
