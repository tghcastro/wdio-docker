FROM --platform=linux/amd64 ubuntu:22.04

RUN apt-get update; apt-get clean

# Install wget.
RUN apt-get install -y wget

RUN apt-get install -y gnupg

# Set the Chrome repo.
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list

# Install Chrome.
RUN apt-get update && apt-get -y install google-chrome-stable

RUN apt-get install -y curl

#########################################

#FROM --platform=linux/amd64 node:18.18.0 as base
#
##################################################
## Install JDK
##################################################
#
##RUN apt-get update && apt-get install -y openjdk-11-jdk
#
##################################################
## Install Google Chrome Stable
##################################################
#
## Chrome dependency Instalation -----------------
#RUN apt-get update && apt-get install -y \
#ca-certificates \
#fonts-liberation \
#libasound2 \
#libatk-bridge2.0-0 \
#libatk1.0-0 \
#libc6 \
#libcairo2 \
#libcups2 \
#libdbus-1-3 \
#libexpat1 \
#libfontconfig1 \
#libgbm1 \
#libgcc1 \
#libglib2.0-0 \
#libgtk-3-0 \
#libnspr4 \
#libnss3 \
#libpango-1.0-0 \
#libpangocairo-1.0-0 \
#libstdc++6 \
#libx11-6 \
#libx11-xcb1 \
#libxcb1 \
#libxcomposite1 \
#libxcursor1 \
#libxdamage1 \
#libxext6 \
#libxfixes3 \
#libxi6 \
#libxrandr2 \
#libxrender1 \
#libxss1 \
#libxtst6 \
#lsb-release \
#wget \
#xdg-utils
#
## Chrome Stable instalation -----------------------------------
#RUN curl -LO  https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
#RUN apt-get install -y ./google-chrome-stable_current_amd64.deb
#RUN rm google-chrome-stable_current_amd64.deb
#RUN echo "Chrome: " && google-chrome --version
#
##################################################
## Install NVM and Node 14.16.1
##################################################
ENV NVM_DIR .
ENV PROJECT_NODE_VERSION 18.18.0
ENV NEWER_NODE_VERSION 16.16.0
ENV CHROME_VERSION 119.0.6045.123
ENV CHROMEDRIVER_HOME /chromedriver/$CHROME_VERSION/chromedriver-linux64

RUN curl https://raw.githubusercontent.com/creationix/nvm/v0.39.5/install.sh | bash \
  && . $NVM_DIR/nvm.sh \
  && nvm install $PROJECT_NODE_VERSION \
#  && nvm install $NEWER_NODE_VERSION \
  && nvm alias default $PROJECT_NODE_VERSION \
#     && nvm use $NEWER_NODE_VERSION \
#     && npx @puppeteer/browsers install chrome@$CHROME_VERSION \
#     && npx @puppeteer/browsers install chromedriver@$CHROME_VERSION \
  && nvm use default
#     && mv /usr/bin/chromedriver /usr/bin/chromedriver-old \
#     && ln -fs $CHROMEDRIVER_HOME/chromedriver /usr/bin/chromedriver

ENV NODE_PATH /versions/node/v$PROJECT_NODE_VERSION/lib/node_modules
ENV PATH      /versions/node/v$PROJECT_NODE_VERSION/bin:$PATH

##################################################
## Install Chrome For Testing and Chromedriver
##################################################

RUN apt-get install -y unzip

ENV CHROME_VERSION=120.0.6099.18

RUN curl -o chrome-linux64.zip https://edgedl.me.gvt1.com/edgedl/chrome/chrome-for-testing/$CHROME_VERSION/linux64/chrome-linux64.zip \
  && unzip -q chrome-linux64.zip -d /chrome-for-testing \
  && rm -f chrome-linux64.zip

ENV PATH      /chrome-for-testing/chrome-linux64:$PATH

RUN curl -o chromedriver-linux64.zip https://edgedl.me.gvt1.com/edgedl/chrome/chrome-for-testing/$CHROME_VERSION/linux64/chromedriver-linux64.zip \
  && unzip -q chromedriver-linux64.zip -d /chrome-for-testing \
  && rm -f chromedriver-linux64.zip

ENV PATH      /chrome-for-testing/chromedriver-linux64:$PATH
#
#
#
##################################################
## Copy and Install Test Project
##################################################

WORKDIR ui-test

COPY package-lock.json .
COPY package.json .

RUN npm install

COPY . .
