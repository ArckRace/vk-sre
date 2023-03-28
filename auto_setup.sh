#!/bin/bash

# Создание пользователей
useradd -m -G sudo -s /bin/bash -p "d.alexeev" d.alexeev
useradd -m -G sudo -s /bin/bash -p "s.ivannikov" s.ivannikov

# Разделение диска, создание /var
lvcreate -L30G -n lvVAR vgKVM
mkfs.ext4 /dev/mapper/vgKVM-lvVAR
mount /dev/mapper/vgKVM-lvVAR /var
echo "/dev/mapper/vgKVM-lvVAR /var ext4 defaults 0 1" >> /etc/fstab

# Создание файла подкачки с swapon
fallocate -l 4G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon -v /swapfile
echo "/swapfile none swap sw 0 0" >> /etc/fstab

# Настройка iptables
