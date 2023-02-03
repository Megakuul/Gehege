# M169 - Container Betreiben



Linus Moser

Inf2021c

03.02.2023

Version 1.0.0



## Inhaltsverzeichnis

- Tag 1	 - Docker Grundlagen
- Tag 2	 - Docker Images
- Tag 3 - Docker Compose
- Tag 4 - Repository
- Tag 5 -	Kubernetes
- Tag 6 -  Kubernetes Deployments
- Tag 7 -  Kubernetes Loadbalancer
- Tag 8 -  Überwachung
- Tag 9 -  Projekt

## Tag 1 - Docker Grundlagen



**Kurze Beschreibung, was Container sind und wo diese nützlich sind.**

Container sind eine Möglichkeit, um Applikationen auszuführen. Sie laufen isoliert voneinander und verwenden im Vergleich zur Virtualisierung nicht ein ganzes Betriebssystem. Container sind portabel und können auf jedem Container Host mit ausgeführt werden. Mit Tools wie Kubernetes kann man Container zudem extrem gut und ausfallsicher skalieren und betreiben.

Quelle: Ich

**Kurze Beschreibung zu was ist Devops?**

DevOps ist eine Kultur, ein Set von Praktiken und Werkzeugen, das die Zusammenarbeit und Kommunikation zwischen Entwicklern und IT-Betriebsteams verbessert. Es zielt darauf ab, die Geschwindigkeit und Qualität von Anwendungsentwicklungsprozessen zu verbessern, indem sichergestellt wird, dass sich die Entwicklung und der Betrieb eng abstimmen.

Quelle: Internet

**Eintrag zu Unterschied Virtualisierung und Containerisierung.**

Der Hauptunterschied zwischen Container und Virtualisierungen ist, wie sie die Ressourcen des Systems teilen:

**Virtualisierung**: Hier wird eine vollständige virtuelle Maschine erstellt, die ihr eigenes Betriebssystem, Speicher und Netzwerkeinstellungen hat. Jede virtuelle Maschine ist isoliert und unabhängig voneinander, aber sie teilen sich die Hardware-Ressourcen des Host-Systems.

**Containerisierung**: Hier werden mehrere Container auf einem einzigen Host-Betriebssystem ausgeführt. Jeder Container enthält seine eigene Anwendung und Abhängigkeiten, aber sie teilen sich das Betriebssystem des Hosts. Daher sind Container effizienter und benötigen weniger Ressourcen als virtuelle Maschinen.

Quelle: Internet + Ich

**Printscreen bei Play with Docker eingeloggt.**

![](https://slabstatic.com/prod/uploads/8q5jdj6q/posts/images/ehU5tS9I6h79qQgjCE57pCRn.png)

**Eintrag zu Unterschied Image und Container**

Der Unterschied zwischen ihnen ist wie folgt:

**Image:** Ein Image ist eine Vorlage für einen Container, also ein &quot;Blueprint&quot; sozusagen. Es enthält alle Dateien, Abhängigkeiten und Konfigurationen, die für die Ausführung der Anwendung erforderlich sind. Ein Image ist statisch und kann nicht geändert werden, aber es kann mehrere Male als Container gestartet werden. Man kann ein Image mit einem Dockerfile erstellen. Bei Images werden mehrere Layer übereinander gelegt, z.B. kann man eine NodeJS Applikation auf ein NodeJS Base Image legen, das NodeJS Image ist dabei auch einfach eine NodeJS Applikation, die auf ein Linux Base Image gelegt wurde.

**Container:** Ein Container ist eine laufende Instanz eines Images. Es ist eine isolierte Umgebung, in der eine Anwendung ausgeführt wird. Containers können ein eigenes Dateisystem, Netzwerkkonfigurationen und Prozesse haben, aber sie teilen sich das Betriebssystem des Hosts.

Quelle: Ich

**Zusammenfassung der wichtigsten Befehle und ihre Funktion**

Images von Docker anzeigen

```
docker images

```

Laufende Container anzeigen

```
docker ps

```

Force delete Container

```
docker rm -f [containerid]

```

Force delete Image

```
docker image rm -f [imageid]

```

Docker Image herunterladen

```
docker pull [image:tag]

```

Docker Container mit Docker Run starten (mit angehefteter Konsole)								(Port 777 exposed)

```
docker run --name [image] -p 777:80

```

Docker Container mit Docker Run starten (mit entkoppelter Konsole)

(Port 777 exposed)

```
docker run --name [image] -d -p 777:80

```

Docker Compose Datei ausführen

```
docker-compose -f [path] up -d

```



**PrintScreen OnlyOffice mit eigenem Namen und Datum im Dokument**

![](https://slabstatic.com/prod/uploads/8q5jdj6q/posts/images/p0iPlHDPeDk5dm0ZlATRqi_g.png)



## Tag 2 - Docker Images



**PrintScreen der Images bei GitLab**

Anstelle des Beispiels habe ich eine eigene Software verwendet. Die Dockerfiles und den Code findet man unter [diesem](https://github.com/Megakuul/gehege) Link.



**Aufgabe 1 bei &quot;Ein Image Pushen&quot;, Halten Sie alle Befehle im Portfolio fest.**

Docker Image erstellen

```
docker build .

```

Image tagen (mit repository name)

```
docker tag [imageid] [repositoryurl]

```

Image pushen

```
docker push [repositoryurl]

```

Docker komplett säubern

```
docker system prune  --all --volumes

```

Image von Repository pullen

```
docker pull [repositoryurl/imagename:tag]

```



**App Version 2 Frontend. PrintScreen der Images bei GitLab**

Wie schon gesagt, benutze ich hier zwei eigene Images. Zudem habe ich diese auf Docker Hub gepusht.

![](https://slabstatic.com/prod/uploads/8q5jdj6q/posts/images/4Yem7YnHT60v8NVJvCD0SK3w.png)



**Zusammenfassung der wichtigsten Befehle und ihre Funktion**

→ Siehe oben:  **_Aufgabe 1 bei &quot;Ein Image Pushen&quot;, Halten Sie alle Befehle im Portfolio fest._**



## Tag 3 - Docker Compose

**Kurze Beschreibung was Docker Compose ist**

Docker Compose ist ein Werkzeug zur Definition und Verwaltung mehrerer Docker-Container als eine einzige Anwendung. Es ermöglicht die Konfiguration aller Container in einer einzigen Datei und den einfachen Start, Stoppen und Überwachen aller Container mit einem einzigen Befehl.

Quelle: Internet + Ich

**Version 2 der App mit Docker Compose zum Laufen gebracht. Vorgehen, Befehle und Compose Datei im Portfolio festgehalten**

Ich habe auch hier natürlich die eigene Software &quot;Gehege&quot; verwendet, daher ist auch das Docker Compose file von dieser Software.

Das untenstehende Docker Compose file installiert einen MongoDB Container und eine Backend-API. Zudem auch den Frontendcontainer.

```
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
    image: gehege:api
    environment:
      PORT: 6004
      DB_HOST: 172.14.0.10
      DB_PORT: 27017
      DB_USER: root
      DB_PASSWORD: rootpassword
      DB_DATABASE: gehege
    ports:
      - 6004:6004
    networks:
      con_mongodb_api:
        ipv4_address: 172.14.0.20
  frontend_container:
    image: gehege:frontend
    ports:
      - 6005:80
    environment:
      API_URL: https://api.url.com

```

**Portainer installiert**



**App via Portainer installiert und im Portfolio festgehalten**



**Den Sock-Shop via Docker Compose installiert. Vorgehen im Portfolio festgehalten.**





## Tag 4 - Repository



## Tag 5 - Kubernetes



## Tag 6 - Kubernetes Deployment



## Tag 7 - Kubernetes Loadbalancer



## Tag 8 - Überwachung



## Tag 9 - Projekt
