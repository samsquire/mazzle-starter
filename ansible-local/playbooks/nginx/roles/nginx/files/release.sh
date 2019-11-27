#!/bin/bash

testing_now=$(ls -l ./ | grep testing)
if [[ "$testing_now" == *blue ]]
then
  testing="blue"
  active="green"
else
  testing="green"
  active="blue"
fi

#remove current links
rm ./available
rm ./testing
rm -f /etc/nginx/nginx.conf
#create new links with the active/inactive reversed
ln -s ./$testing ./available
ln -s ./$active ./testing
ln -s /home/ubuntu/spring/$active/nginx.conf /etc/nginx/nginx.conf
#reload the http server
service nginx reload
echo swap completed $active is now available
