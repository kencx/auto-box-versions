#!/bin/sh -eux
ip -br a

apt -y purge ppp pppconfig pppoeconf
apt -y purge popularity-contest

apt -y autoremove
apt -y clean

find /var/cache -type f -exec rm -rf {} \;
find /var/log -type f -exec truncate --size=0 {} \;

rm -rf /tmp/* /var/tmp/*

rm -f /root/.wget-hsts
export HISTSIZE=0
