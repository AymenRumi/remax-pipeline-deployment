#!/bin/bash



# sudo yum install -y python3-pip
# pip3 install remax-pipeline

echo "Hello" >> testfile.txt
sudo wget https://chromedriver.storage.googleapis.com/2.37/chromedriver_linux64.zip
sudo unzip chromedriver_linux64.zip
sudo mv chromedriver /usr/bin/chromedriverchromedriver --version

sudo curl -k https://intoli.com/install-google-chrome.sh | bash
sudo mv /usr/bin/google-chrome-stable /usr/bin/google-chrome
sudo google-chrome --version && which google-chrome >> chromefile.txt


which pip3 >> t.txt

sudo yum install -y python3-pip



which pip3 >> whichpip.txt

pwd >> pwd.txt

# pip3 install celery > install_log.txt 2>&1

pip3 install --ignore-installed remax-pipeline > remax_install_log.txt 2>&1


pip3 freeze > requirements.txt


celery >> celery.txt