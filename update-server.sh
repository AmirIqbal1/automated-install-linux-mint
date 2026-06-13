#!/bin/bash
set -e

echo "Starting server update..."

echo "Fixing any interrupted apt/dpkg jobs..."
sudo dpkg --configure -a
sudo apt install -f -y

echo "Updating Ubuntu packages..."
sudo apt update
sudo apt upgrade -y

#echo "Updating Docker images and containers..."

#if command -v docker compose >/dev/null 2>&1; then
#  for dir in /opt/docker/* /opt/stacks/*; do
#    if [ -f "$dir/docker-compose.yml" ] || [ -f "$dir/compose.yml" ]; then
#      echo "Updating stack: $dir"
#      cd "$dir"
#      sudo docker compose pull
#      sudo docker compose up -d
#    fi
#  done
#fi

#echo "Cleaning Docker..."
#sudo docker image prune -f
#sudo docker container prune -f
#sudo docker network prune -f

echo "Cleaning Ubuntu..."
sudo apt autoremove -y
sudo apt autoclean
sudo apt clean

echo "=================================================="
if [ -f /var/run/reboot-required ]; then
  echo "Reboot required. Run: sudo reboot"
else
  echo "Update complete. No reboot required."
fi
echo "=================================================="
