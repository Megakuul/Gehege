FROM node:14
MAINTAINER Oberscheff

WORKDIR /usr/src/app

COPY package*.json ./

RUN npm install --only=production

COPY . .

CMD npm start