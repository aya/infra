##
# DEPLOY

.PHONY: aws-codedeploy
aws-codedeploy:
	$(call aws,deploy create-deployment \
				--application-name $(CODEDEPLOY_APP_NAME) \
		        --deployment-config-name $(CODEDEPLOY_DEPLOYMENT_CONFIG) \
		        --deployment-group-name $(CODEDEPLOY_DEPLOYMENT_GROUP) \
		        --description "$(CODEDEPLOY_DESCRIPTION)" \
		        --github-location repository=$(CODEDEPLOY_GITHUB_REPO)$(comma)commitId=$(CODEDEPLOY_GITHUB_COMMIT_ID))
