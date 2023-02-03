FROM nginx:latest
MAINTAINER Oberscheff

COPY ./build/web /usr/share/nginx/html

WORKDIR /usr/share/nginx/html

CMD ["nginx", "-g", "daemon off;"]