#!/bin/bash
echo "PASTE YOUR .PEM CONTENT HERE"> /home/ubuntu/key_name.pem
chmod 400 /home/ubuntu/key_name.pem
chown ubuntu:ubuntu /home/ubuntu/key_name.pem