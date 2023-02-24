#!/bin/bash
cp test_service.sh /usr/bin/test_service.sh
chmod +x /usr/bin/test_service.sh
cp myservice.service /etc/systemd/system/myservice.service
chmod 644 /etc/systemd/system/myservice.service
systemctl start myservice
systemctl status myservice
