#!/bin/bash

sudo wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo apt install ./google-chrome-stable_current_amd64.deb -y

cd spring-petclinic-angular
npm i
npm run test-headless
cd ..
cd spring-petclinic-rest
./mvnw clean test