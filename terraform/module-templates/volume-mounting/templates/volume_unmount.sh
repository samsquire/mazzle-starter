#!/bin/bash

umount ${mount_point}

device_name=${device_name}
instance_id=$(ec2metadata --instance-id)
volume_id=$(aws ec2 describe-tags --filters "Name=resource-id,Values=$instance_id" "Name=resource-type,Values=instance" "Name=key,Values=Volume" --region eu-west-2 | jq -r '.Tags[0].Value')

echo $instance_id
echo $volume_id

aws ec2 detach-volume --volume-id $volume_id --instance-id $instance_id --device ${device_name} --region eu-west-2


