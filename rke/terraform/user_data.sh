#!/bin/bash


curl https://releases.rancher.com/install-docker/18.09.sh | sh
sudo usermod -aG docker ubuntu
