FROM --platform=linux/amd64 ubuntu:22.04

##################################################
# Install Linux Tools and Libraries
##################################################

RUN apt-get update && apt-get clean && apt-get install -y \ 
  wget \
  gnupg \
  curl \
  unzip

##################################################
# Install Google Chrome Stable
##################################################

# Set the Chrome repo
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
  && echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list

# Install Chrome.
RUN apt-get update && apt-get -y install google-chrome-stable

##################################################
## Install JDK
##################################################

#RUN apt-get update && apt-get install -y openjdk-11-jdk

##################################################
## Install NVM and Node 14.16.1
##################################################
ENV NVM_DIR .
ENV PROJECT_NODE_VERSION 18.18.0

RUN curl https://raw.githubusercontent.com/creationix/nvm/v0.39.5/install.sh | bash \
  && . $NVM_DIR/nvm.sh \
  && nvm install $PROJECT_NODE_VERSION \
  && nvm alias default $PROJECT_NODE_VERSION \
  && nvm use default

ENV NODE_PATH /versions/node/v$PROJECT_NODE_VERSION/lib/node_modules
ENV PATH /versions/node/v$PROJECT_NODE_VERSION/bin:$PATH

##################################################
## Install Chrome For Testing and Chromedriver
##################################################

ENV CHROME_VERSION 119.0.6045.159

RUN curl -o chrome-linux64.zip https://edgedl.me.gvt1.com/edgedl/chrome/chrome-for-testing/$CHROME_VERSION/linux64/chrome-linux64.zip \
  && unzip -q chrome-linux64.zip -d /chrome-for-testing \
  && rm -f chrome-linux64.zip

ENV PATH /chrome-for-testing/chrome-linux64:$PATH

RUN curl -o chromedriver-linux64.zip https://edgedl.me.gvt1.com/edgedl/chrome/chrome-for-testing/$CHROME_VERSION/linux64/chromedriver-linux64.zip \
  && unzip -q chromedriver-linux64.zip -d /chrome-for-testing \
  && rm -f chromedriver-linux64.zip

ENV PATH /chrome-for-testing/chromedriver-linux64:$PATH

##################################################
## Copy and Install Test Project
##################################################

WORKDIR ui-test

COPY package-lock.json .
COPY package.json .

RUN npm install

COPY . .

ENTRYPOINT ["npm", "run", "wdio"]
