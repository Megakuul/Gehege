# Gehege Docker Project

Note that this project doesn&#39;t follow best practices, since the UI was created last second before project submission, it&#39;s not good-looking and the Flutter code is also extremely unreadable.

The Project should be an example to deploy on **Docker/Kubernetes** or the **Cloud**.

## Build

Note that you need the Flutter SDK, Typescript and Docker installed to build the image.

To manually build the project, you can go to the `web` directory and execute the bash script (`build.bash`), or alternative the following code:

```bash
cd ./web/ && flutter build web --web-renderer canvaskit -o ../src/public

```

This will build the **frontend** and copy it to the `public` directory where the API will serve it.

Now you can transpile the API (only required if changes have been made):

```bash
cd ./src/public && tsc

```

Finally build the Docker Image:

```bash
docker build -t megakuul/gehege:latest ./src/

```

## Deployment

### Deployment with Docker-Compose

Note that you can also use a external MongoDB database

Docker-Compose file looks like that:

```yaml
version: '3.7'

networks:
  con_mongodb_api:
    driver: bridge
    ipam:
      config:
        - subnet: 172.14.0.0/16
          gateway: 172.14.0.1

services:
  mongodb_container:
    image: mongo:latest
    environment:
      MONGO_INITDB_ROOT_USERNAME: root
      MONGO_INITDB_ROOT_PASSWORD: rootpassword
    ports:
      - 27017:27017
    volumes:
      - ./data/db:/data/db
    networks:
      con_mongodb_api:
        ipv4_address: 172.14.0.10

  api_container:
    image: megakuul/gehege:latest
    environment:
      PORT: 6004
      DB_HOST: 172.14.0.10
      DB_PORT: 27017
      DB_USER: root
      DB_PASSWORD: rootpassword
      DB_DATABASE: gehege
      GEHEGE_ADMIN: admin
      GEHEGE_ADMIN_PW: adminpassword
    ports:
      - 6004:6004
    networks:
      con_mongodb_api:
        ipv4_address: 172.14.0.20

```

## API Docs

Basic overview about the API patterns

### /signup

Type: POST

Headers:

- Content-Type → application/json

Body:

```javascript
{
    "username": "Example",
    "password": "Examplepassword",
    "description": "Exampledescription"
}

```

### /createtok

Type: POST

### /getuserinfo

Type: GET

### /changeuserinfo

Type: POST

Headers:

- Content-Type → application/json

Body:

```javascript
{
    "description": "Exampledescription",
    "password": "Examplepassword"
}

```

### /getgehege

Type: GET

### /creategehege

Type: POST

Headers:

- Content-Type → application/json

Body:

```javascript
{
    "gehege_name": "Examplegehege",
    "imageBase64String": "123456"
}

```

### /donate

Type: POST

Headers:

- Content-Type → application/json

Body:

```javascript
{
    "gehegename": "Example",
    "cash": 10
}

```
