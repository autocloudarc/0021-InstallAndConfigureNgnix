#!/bin/bash
<<HEADER
DESCRIPTION: This is a simple script that can be used to install and configure NGNIX on CentOS 7.0+ Linux systems.
REQUIREMENTS: CentOS 7.0+, root or sudo permissions
ARGUMENTS: NA
EXAMPLE: InstallAndConfigureNginx.sh
SYNTAX for Azure CLI using Linux custom script extensions:
az vm extension set \
  --resource-group <resource-group-name> \
  --vm-name <vm-name> \
  --name CustomScriptForLinux \
  --version 1.0 \
  --publisher Microsoft.OSTCExtensions \
  --settings '{"fileUris": ["fileUri"],"commandToExecute": "bash <script-file>.sh"}'     	
KEYWORDS: Azure, Custom, Script, Extension, Linux

LICENSE:
MIT License

Copyright (c) 2017 Preston K. Parsard

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the SoftwSare is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.
S
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

LEGAL DISCLAIMER:
This Sample Code is provided for the purpose of illustration only and is not intended to be used in a production environment.� 
THIS SAMPLE CODE AND ANY RELATED INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, 
INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.� 
We grant You a nonexclusive, royalty-free right to use and modify the Sample Code and to reproduce and distribute the object code form of the Sample Code, provided that You agree: 
(i) to not use Our name, logo, or trademarks to market Your software product in which the Sample Code is embedded; 
(ii) to include a valid copyright notice on Your software product in which the Sample Code is embedded; and 
(iii) to indemnify, hold harmless, and defend Us and Our suppliers from and against any claims or lawsuits, including attorneys� fees, that arise or result from the use or distribution of the Sample Code.
This posting is provided "AS IS" with no warranties, and confers no rights.

REFERENCES:
1. https://docs.microsoft.com/en-us/azure/virtual-machines/linux/tutorial-automate-vm-deployment
2. https://www.tecmint.com/install-nginx-on-centos-7/

HEADER

# Preserve original configuration files that will be updated
# Preserve original configuration files that will be updated
siteUser="linux.user"
wwwOwner="www-data"
sitePath="/etc/nginx/sites-available"
siteFile="$sitePath/default"
indexPath="/home/$siteUser/myapp"
indexFile="$indexPath/index.js"

# Updgrade the instance 
yum -y upgrade 
# Update the system software packages
yum -y update 

# Install Nginx HTTP server from the EPEL repository
yum -y install epel-release
yum -y install nginx
yum -y install nodejs
yum -y install npm

# Write configuration file
mkdir $sitePath
touch $siteFile
chown $wwwOwner:$wwwOwner $siteFile 
cat > $siteFile << EOF
      server {
        listen 80;
        location / {
          proxy_pass http://localhost:3000;
          proxy_http_version 1.1;
          proxy_set_header Upgrade $http_upgrade;
          proxy_set_header Connection keep-alive;
          proxy_set_header Host $host;
          proxy_cache_bypass $http_upgrade;
        }
      }
EOF

# Write node file
mkdir ~/myapp 
touch $indexFile
chown $siteUser:$siteUser $indexFile
cat > $indexFile << EOF
      var express = require('express')
      var app = express()
      var os = require('os');
      app.get('/', function (req, res) {
        res.send('Hello World from host ' + os.hostname() + '!')
      })
      app.listen(3000, function () {
        console.log('Hello world app listening on port 3000!')
      })
EOF

# Start NGNIX 
systemctl start nginx
cd $indexPath

# Initialize npm
npm init 
npm install express -y 
nodejs index.js 

# Enable NGNIX to start automatically after reboot
systemctl enable nginx

# Update system firewall rules
firewall-cmd --zone=public --permanent --add-service=https
firewall-cmd --reload

# FOOTER

