AWS_DEFAULT_REGION              ?= eu-west-1
AWS_DEFAULT_OUTPUT              ?= text
AWS_PROFILE                     ?= default
AWS_SNAPSHOT_ROLE_NAME          ?= vmimport
AWS_SNAPSHOT_S3_BUCKET          ?= enova-aws-config
AWS_SNAPSHOT_S3_KEY             ?= alpine-3.9.2-x86_64.iso
CMDS                            += aws
ENV_SYSTEM_VARS                 += AWS_SNAPSHOT_S3_KEY AWS_SNAPSHOT_S3_BUCKET
