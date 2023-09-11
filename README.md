# Holi Chat Server

Holi Chat Server is a [Matrix Synapse](https://matrix-org.github.io/synapse/latest/) chat server application that allows holi users to communicate with each other in real-time.

## Installation:

To run Holi Chat Server locally, follow these steps:

1. Clone the repository.
2. Navigate to the project directory using a terminal or command prompt.
3. Fill your .envrc.local and .envrc-push-gateway.local file with secrets from passbolt
4. Create the file _data-push-gateway/apns_keyfile_staging.p8_ and fill it with the secret. Manually format it so that it looks like a ssh key.
5. Run the configuration scripts by running the following command:

```
./generate-homeserver-config.sh
./generate-push-gateway-config.sh
```

This will generate a default configuration file for your server.

7. Add `local.chat.holi.social` entry to your `/etc/hosts` file as follows:

```
127.0.0.1 local.chat.holi.social
```

8. Authenticate Docker with our Gitlab Container Registry to be able to pull our [custom sygnal image](https://gitlab.holi.team/app/holi-chat-server/container_registry)
You will need to create a personalized [gitlab access token](https://gitlab.holi.team/app/holi-chat-server/-/settings/access_tokens) with _read_registry_ rights

9. 
```
docker login gitlab.holi.team:5050
```

10. Start the server by running the following command:

```
docker compose up -d
```

This will start the server in the background and you can access the application by navigating to [https://local.chat.holi.social](https://local.chat.holi.social) in your web browser.

You can run a local element web client like this: 
```
docker run -p 81:80 vectorim/element-web
```
Since the chat server does use a self signed SSL certificate, you first need to open localhost:8448 and trust the cert. You can then open localhost:81 in your browser and change the server you want to connect to to `local.chat.holi.social`.
