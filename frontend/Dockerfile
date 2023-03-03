FROM nginx:latest
MAINTAINER Megakuul

COPY ./build/web /usr/share/nginx/html

WORKDIR /usr/share/nginx/html

CMD sh -c 'sed -i "s/api_url/$API_URL/g" /usr/share/nginx/html/assets/assets/gehege.conf.json && nginx -g "daemon off;"'