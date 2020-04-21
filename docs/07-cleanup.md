# Module 7 - Cleanup

If you conducted this workshop with an account provided by an AWS Event, then cleanup will be handled for you by the presentor, thus there is no remaining action expected of you other than completing the workshop evaluation.
However, if you used your own account, then follow these steps to cleanup your account.

1. Delete the Cloudwatch Event rules and lambdas deployed by Cloud Custodian by running the following command from the Cloud9 IDE's terminal prompt

        wget https://raw.githubusercontent.com/cloud-custodian/cloud-custodian/master/tools/ops/mugc.py
        docker run -it --rm --cap-drop ALL -v /home/ec2-user/environment/securityhub-remediations:/home/custodian/securityhub-remediations:ro -v /home/ec2-user/.aws:/home/custodian/.aws:ro --entrypoint /usr/local/bin/python ${SECHUBWORKSHOP_CONTAINER} securityhub-remediations/mugc.py --present -c  securityhub-remediations/module3/ec2-sechub-custom-actions.yml

2. Run the following commands.  If you get errors, then it could be that [cleanup of custom actions was added to the mugc.py](https://github.com/cloud-custodian/cloud-custodian/issues/4884)

        ACCOUNTID=$(aws sts get-caller-identity --query Account --output text)
        aws securityhub delete-action-target --action-target-arn arn:aws:securityhub:${AWS_DEFAULT_REGION}:${ACCOUNTID}:action/custom/DenySnapStop
        aws securityhub delete-action-target --action-target-arn arn:aws:securityhub:${AWS_DEFAULT_REGION}:${ACCOUNTID}:action/custom/DisableKey
        aws securityhub delete-action-target --action-target-arn arn:aws:securityhub:${AWS_DEFAULT_REGION}:${ACCOUNTID}:action/custom/PostOpsItem
        aws securityhub delete-action-target --action-target-arn arn:aws:securityhub:${AWS_DEFAULT_REGION}:${ACCOUNTID}:action/custom/RemPA
        aws securityhub delete-action-target --action-target-arn arn:aws:securityhub:${AWS_DEFAULT_REGION}:${ACCOUNTID}:action/custom/Delete

3. Delete the CloudFormation stack created in module 1 (**SecurityHubRemediations**)
	* Go to the <a href="https://console.aws.amazon.com/cloudformation/home#/stacks?filter=active">AWS CloudFormation</a> console.
	* Select the appropriate stack.
	* Select **Action**.
	* Click **Delete Stack**.

4.	While we strongly recommend you leave GuardDuty enabled, however if you really want to disable it, perform the following:
	* Go to the <a href="https://console.aws.amazon.com/guardduty/" target="_blank">Amazon GuardDuty</a> console.
	* Click **Settings** in the navigation pane on the left navigation.
	* Click the check box next to **Disable**.
	* Click **Save settings** and then click **Disable** in the pop-up box.

5.	While we strongly recommend you leave Security Hub enabled, however if you really want to disable it, perform the following:
	* Go to the <a href="https://console.aws.amazon.com/securityhub/home?region=us-west-2#/findings" target="_blank">AWS Security Hub</a> console.
	* Click on **Settings** on the left navigation.
	* Click the **General** on the top navigation.
	* Click **Disable AWS Security Hub**.

6. You have completed both this module and the Workshop.  Congrats!
