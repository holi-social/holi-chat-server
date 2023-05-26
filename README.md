# Holi Chat Server

Holi Chat Server is a [Matrix Synapse](https://matrix-org.github.io/synapse/latest/) chat server application that allows holi users to communicate with each other in real-time.

## Installation:

To run Holi Chat Server locally, follow these steps:

1. Clone the repository.
2. Navigate to the project directory using a terminal or command prompt.
3. Fill your .envrc.local file with the following information:

```
export HOLI_CHAT_ORY_CLIENT_ID=<from Passbolt>
export HOLI_CHAT_ORY_CLIENT_SECRET=<from Passbolt>
export HOLI_CHAT_REGISTRATION_SHARED_SECRET=<any random string>
export HOLI_CHAT_MACAROON_SECRET_KEY=<any random string>
export HOLI_CHAT_FORM_SECRET=<any random string>
```

4. Run the configuration script by running the following command:

```
./generate-homeserver-config.sh
```

This will generate a default configuration file for your server.

5. Add `local.chat.holi.social` entry to your `/etc/hosts` file as follows:

```
127.0.0.1 local.chat.holi.social
```

6. Start the server by running the following command:

```
docker-compose up -d
```

This will start the server in the background and you can access the application by navigating to [https://local.chat.holi.social](https://local.chat.holi.social) in your web browser.
