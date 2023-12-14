#!/bin/bash


sudo wget https://chromedriver.storage.googleapis.com/2.37/chromedriver_linux64.zip
sudo unzip chromedriver_linux64.zip
sudo mv chromedriver /usr/bin/chromedriverchromedriver --version

sudo curl -k https://intoli.com/install-google-chrome.sh | bash
sudo mv /usr/bin/google-chrome-stable /usr/bin/google-chrome
sudo google-chrome --version && which google-chrome 



sudo yum install -y python3-pip



pip3 install --ignore-installed remax-pipeline



