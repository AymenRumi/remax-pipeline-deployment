#!/bin/bash

sudo yum update
wget https://chromedriver.storage.googleapis.com/2.37/chromedriver_linux64.zip
unzip chromedriver_linux64.zip
sudo mv chromedriver /usr/bin/chromedriverchromedriver --version

curl https://intoli.com/install-google-chrome.sh | bash
sudo mv /usr/bin/google-chrome-stable /usr/bin/google-chrome
google-chrome --version && which google-chrome


sudo yum install -y python3-pip

pip3 install remax-pipeline