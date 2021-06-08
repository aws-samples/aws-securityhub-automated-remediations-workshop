# Module 6 - Remediate an Public EBS-Snapshot

This module will show how to setup an automated detection of a EBS Snaspshot that has been made public, with a finding submitted to Security Hub, then use Security Hub Custom action to delete the snapshot.  Then we'll fully automate the remediation by changing the detection policy to perform the delete while still providing notification.

1. Start by reviewing the file "post-ebs-snapshot-public.yml" using the Cloud9 IDE.
   Observe that both polices in the file have a mode type of cloudtrail, with an event configuration filtering on eventname ModifySnapshotAttribute

2. Then deploy the automated detection policy by running the following command:

        ${CLOUDCUSTODIANDOCKERCMD} aws-securityhub-automated-remediations-workshop/module6/post-ebs-snapshot-public.yml

3. Skip to the next step if you are using an AWS Event provided account.  Only if you have ebs-encryption-by-default enabled, you will need to disabling it for purposes of this module, by running the following:

        aws ec2 disable-ebs-encryption-by-default

4. Next we need to create a new EBS volume, however no data will be stored in it, it will not be attached anywhere.  Note how the VolumeId is saved for the next step.

        export WorkshopVolumeId=$(aws ec2 create-volume --availability-zone $(aws ec2 describe-availability-zones --query AvailabilityZones[0].ZoneName --output text) --size 1 --tag-specifications  'ResourceType=volume,Tags=[{Key=CostCenter,Value=SecurityHubWorkshop},{Key=Name,Value=SecurityHubWorkshopModule6Volume}]' --no-encrypted --query VolumeId --output text)

5. Then we Snapshot the volume just created, also saving the SnapshotId for a future step.

        export WorkshopSnapshotId=$(aws ec2 create-snapshot --volume-id $WorkshopVolumeId --description 'Module6: Take a snapshot of a empty volume, then make it public, then remediate' --tag-specifications  'ResourceType=snapshot,Tags=[{Key=CostCenter,Value=SecurityHubWorkshop},{Key=Name,Value=SecurityHubWorkshopModule6Volume}]' --query SnapshotId --output text)

6. This step makes the snapshot public.  If it fails with 'An error occurred (OperationNotPermitted) when calling the ModifySnapshotAttribute operation: Encrypted snapshots cannot be shared publicly' then either you skipped step the step earlier to disable it, or someone/someprocess enabled it in the meantime.

        aws ec2 modify-snapshot-attribute --snapshot-id $WorkshopSnapshotId --attribute createVolumePermission --operation-type add --group-names all

7. Now navigate to the Findings part of Security Hub's console.
   Look for a finding who's title is the same as the policy name from step 1, if you don't see it, you may need to wait, usually less than 20 seconds but sometimes up to 2 minutes.
   Observe that the Status column for the finding is "FAILED".
8. Manually remediate the Public Snapshot by running the following:

        aws ec2 modify-snapshot-attribute --snapshot-id $WorkshopSnapshotId --attribute createVolumePermission --operation-type remove --group-names all

9. After about 20 seconds, refresh the Security Hub's console, looking for the same finding's Status column value now be "PASSED", or refresh every 10-20 seconds until it does change.
   The 2nd policy contained in the policy file deployed in this module detected that the snapshot was no longer public, so it invoked the action post-finding, setting the compliance status to PASSED and due to setting the finding's title to be the same as that of the policy that reported the failure, an update to the prior finding was performed, then the 2nd action was to remove the finding_id from the resource so that any future reoccurance of it being made public will be treated as a new finding.
10. Click the checkbox to the left of the Finding then click the button "Workflow status" and select "Resolved".

9. Now test a custom action by clicking the checkbox for the finding then click the dropdown for Actions then select "Ebs-Snapshot Delete" (This custom action is one of the ones deployed in Module 3).
8. Confirm the snapshot got deleted by running:

        aws ec2 describe-snapshots --snapshot-ids $WorkshopSnapshotId

   then confirming the response is similar to:

        An error occurred (InvalidSnapshot.NotFound) when calling the DescribeSnapshots operation: The snapshot 'snap-0643b6dcd0a6f01f0' does not exist.

9. Now edit the file "post-ebs-snapshot-public.yml" by adding an action to delete the snapshot at time of initial detection, which transform the policy from a detective control to a remediation control.
   Uncomment line 29 by removing the single hash such that the dash should be in column 7.
10. Save the file in the IDE then run the following command which redeploys the policy:

        ${CLOUDCUSTODIANDOCKERCMD} aws-securityhub-automated-remediations-workshop/module6/post-ebs-snapshot-public.yml

12. Run the following three commands:

        export WorkshopSnapshotId=$(aws ec2 create-snapshot --volume-id $WorkshopVolumeId --description 'Module6: Take a snapshot of a empty volume, then make it public, then remediate' --tag-specifications  'ResourceType=snapshot,Tags=[{Key=CostCenter,Value=SecurityHubWorkshop},{Key=Name,Value=SecurityHubWorkshopModule6Volume}]' --query SnapshotId --output text)
        aws ec2 modify-snapshot-attribute --snapshot-id $WorkshopSnapshotId --attribute createVolumePermission --operation-type add --group-names all
        aws ec2 describe-snapshots --snapshot-ids $WorkshopSnapshotId

13. Repeat running the last command, the describe-snapshots one, until either the InvalidSnapshot.NotFound error is received (which means success, move on the the next step)
    or if after 5 minutes it still has not been deleted, the most likely cause is the step to add the delete action did not get done correctly or was not deployed.

14. The remainder of this module shows you how to customize the automated remediation by adding an exception filter then provides information on more advanced filters.
    If you have a use case for publicly sharing a snapshot, a change to the policy could be made to filter for only those snapshots which do not have a specific value for a specific tag.
    In this example we use the Tag key of "PublicIntent" and Tag value of "True".  Start by updating the filter section of the policy by inserting the following lines at line 17,
    as long as it's within the filter section and doesn't overlap the existing filter, with the dash character at column 7.
    The way to read the filter match the condition of not-equal when testing for Tag key of value.
    Thus resources which have this tag value will get filtered out aka excluded, thus the actions will not get invoked on those filtered out resources.

        - type: value
          op: not-equal
          key: "tag:PublicIntent"
          value: "True"

15. Save the file.
16. Deploy the updated policy

        ${CLOUDCUSTODIANDOCKERCMD} aws-securityhub-automated-remediations-workshop/module6/post-ebs-snapshot-public.yml

17. Run the following command noticing that this time it's created with a Tag key and value which matches the filter specified.

        export WorkshopSnapshotId=$(aws ec2 create-snapshot --volume-id $WorkshopVolumeId --query SnapshotId --output text --tag-specifications 'ResourceType=snapshot,Tags=[{Key=PublicIntent,Value=True}]')

18. Run the following to make the snapshot public:

        aws ec2 modify-snapshot-attribute --snapshot-id $WorkshopSnapshotId --attribute createVolumePermission --operation-type add --group-names all

19. Run the following wait then show the snapshot did not get deleted, a result of the exception filter.

        sleep 20 ; aws ec2 describe-snapshots --snapshot-ids $WorkshopSnapshotId

20. For good hygiene, delete the public snapshot and the volume manually.

        aws ec2 delete-snapshot --snapshot-id $WorkshopSnapshotId
        aws ec2 delete-volume --volume-id $WorkshopVolumeId

21.  Only if not using an AWS Event supplied account, and you disabled the EBS encryption by default, then you should proceed with enabling it again by running the following command:

        aws ec2 enable-ebs-encryption-by-default

21. To learn more about the types of filters that can be added to any Cloud Custodian Policy, click [generic filters](https://cloudcustodian.io/docs/filters.html).
22. To learn about the filters that can be applied to EBS Snapshots, run the following:

        docker run -it --rm ${SECHUBWORKSHOP_CONTAINER} schema ebs-snapshot.filters

23. To learn more about the attributes of a specific filter, append the filters name to the command, like the following example for the skip-ami-snapshots filter

        docker run -it --rm ${SECHUBWORKSHOP_CONTAINER} schema ebs-snapshot.filters.skip-ami-snapshots

26. To learn about what AWS resource types are supported by Cloud Custodian, run the following:

        docker run -it --rm ${SECHUBWORKSHOP_CONTAINER} schema aws

27. The actions supported by a specific resource can be viewed by using the schema command with the parameter of <resource_type>.actions, like in the following:

        docker run -it --rm ${SECHUBWORKSHOP_CONTAINER} schema ebs-snapshot.actions

28. And just like filters, the attributes for a given action can be viewed by running the schema command specifing the <resource_type>.actions.<action_name>, like the following:

        docker run -it --rm ${SECHUBWORKSHOP_CONTAINER} schema ebs-snapshot.actions.post-finding

29. You have completed this module.  If you are using an account provided by an AWS Event via EventEngine, then you have completed the Workshop and do not need to proceed with Module 7.  If you are using your own account, then proceeding to module 7 is advised to cleanup resources created during the Workshop.
