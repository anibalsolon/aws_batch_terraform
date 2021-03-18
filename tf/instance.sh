#!/bin/bash

cloud-init-per once docker_options echo 'OPTIONS="$OPTIONS --storage-opt dm.basesize=${storage}G"' >> /etc/sysconfig/docker
