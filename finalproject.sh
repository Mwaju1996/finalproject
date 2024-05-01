#!/bin/bash
####################################
#Author: Diana Mwajuma Nzuki
#Course: Linux and Bash Scripting
#Date: April 30th 2024
#
#About
#This Script I go through the STIGS documentation using STIG viewer, check for the documented
#issues for ubuntu 20.04  and fix any findings.
#
#
#Linux Scripting Course
#
######################################################################################


echo "Checking for empty passwords"
#!/bin/bash

# Run the command to check for blank passwords
results=$(sudo awk -F: '!$2 {print $1}' /etc/shadow)

# Check if there are any results
if [ -n "$results" ]; then
    echo "Blank passwords found. Locking accounts..."
    
    # Loop through each result and lock the account
    while IFS= read -r user; do
        sudo passwd -l "$user"
        echo "Locked account: $user"
    done <<< "$results"
else
    echo "No blank passwords found."
fi
sleep 0.5

 #Group ID: V-238327
 #Rule Title: The Ubuntu operating system must not have the rsh-server package installed
 echo "The Ubuntu Operating system must not have the rsh-server package installed."
 stig_id="V-238327"
 description="Description 2"
 check_command="dpkg -l | grep rsh-server"
 fix_command="apt-get remove rsh-server"
 echo -n "Checking CAT I STIG $stig_id - $description... "
 eval "$check_command"
 if [ $? -eq 0 ]; then
    echo "Not compliant - Attempting to fix..."
    eval "$fix_command"
    if [ $? -eq 0 ]; then
        echo "Fixed"
    else
        echo "Fix failed"
    fi
 else
    echo "Compliant"
 fi

 sleep 0.5

#Severity: CAT II
 #Group ID V-238354
 #Rule Title:The Ubuntu operating system must have an application firewall installed in order to control remote access methods.
 # Check if UFW is installed
if dpkg -l | grep -q "ufw"; then
  echo "UFW is already installed. No action needed."
 else
  echo "Installing UFW..."
  # Install UFW if not already installed
  sudo apt-get install -y ufw
  echo "UFW has been installed."
fi


 #Severity: CAT II
 #Group ID: V-238374
 #Rule Title:The Ubuntu operating system must have an application firewall enabled.
 # Check if UFW is enabled
 if systemctl status ufw.service | grep -q -i "active: active"; then
  echo "UFW is already enabled. No action needed."
 else
  echo "Enabling UFW..."
  # Enable UFW
  sudo systemctl enable ufw.service
  # Start UFW
  sudo systemctl start ufw.service
  echo "UFW has been enabled and started."
 fi

sleep 0.5

#Severity CAT II
 #Group ID V-238334
 #Rule Title: The Ubuntu operating system must disable kernel core dumps  so that it can fail to a secure
 #state if system initialization fails, shutdown fails or aborts fail
 # Check if kdump service is active
 if [ "$(systemctl is-active kdump.service)" == "inactive" ]; then
  echo "The kdump service is already inactive. No action needed."
 else
  echo "Checking if the use of the kdump service is required and documented..."
  # Check if the use of kdump service is documented
  if [ -f "/etc/kdump.conf" ]; then
    echo "The use of the kdump service is documented. No action needed."
  else
    echo "Disabling the kdump service..."
    # Disable the kdump service
    sudo systemctl disable kdump.service
    echo "The kdump service has been disabled."
  fi
 fi
