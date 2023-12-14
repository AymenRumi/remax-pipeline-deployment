#!/bin/bash

# installing chromedriver
sudo wget https://chromedriver.storage.googleapis.com/2.37/chromedriver_linux64.zip
sudo unzip chromedriver_linux64.zip
sudo mv chromedriver /usr/bin/chromedriverchromedriver --version

# installing google chrome
sudo curl -k https://intoli.com/install-google-chrome.sh | bash
sudo mv /usr/bin/google-chrome-stable /usr/bin/google-chrome
sudo google-chrome --version && which google-chrome 

# installing pip
sudo yum install -y python3-pip

# installing remax_pipeline
pip3 install --ignore-installed remax-pipeline



