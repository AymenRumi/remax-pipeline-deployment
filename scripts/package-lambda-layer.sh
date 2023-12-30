#!/bin/bash

mkdir python
pip install -r requirements.txt -t python/
zip -r layer.zip python/
rm -r python
