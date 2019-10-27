#!/bin/bash
device_name=${device_name}
instance_id=$(ec2metadata --instance-id)
volume_id=$(aws ec2 describe-tags --filters "Name=resource-id,Values=$instance_id" "Name=resource-type,Values=instance" "Name=key,Values=Volume" --region eu-west-2 | jq -r '.Tags[0].Value')

echo $instance_id
echo $volume_id

mkdir -p ${mount_point}
chattr +i ${mount_point}
counter=0

function attach {
command="aws ec2 attach-volume --volume-id $volume_id --instance-id $instance_id --device ${device_name} --region eu-west-2"
echo $${command}
$${command}
}

attach
while [ ! -e ${device_name} ] ; do
  echo "${device_name} does not exist yet, sleeping..."
  sleep 30
  counter=$((counter + 1))
  if [ $counter -ge 20 ] ; then
    attach
    counter=0
  fi
done
blkid ${device_name} | grep ext4
is_formatted=$?
if [ $is_formatted -ne 0 ] ; then
  mkfs -t ext4 ${device_name}
  echo "disk needs formatting. formatting..."
fi
mount ${device_name} ${mount_point}
echo "mounted"
