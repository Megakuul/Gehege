#Important: to execute this script, you will need docker and flutter installed
try {
    cd .\src\
    docker build -t gehegeapi .
    cd ..

    cd .\gehege_frontend\
     flutter build web --dart-define=API_URL=http://localhost:6004
    docker build -t gehegefrontend .

    cd ..

    docker-compose up -d
} catch {
    Write-Host "An error occured, make sure Docker and the Flutter SDK is installed!"
}
