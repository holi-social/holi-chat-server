# Holi Chat Server

Holi Chat Server is a [Matrix Synapse](https://matrix-org.github.io/synapse/latest/) chat server application that allows holi users to communicate with each other in real-time.

## Installation:

To run Holi Chat Server locally, follow these steps:

1. Clone the repository.
2. Navigate to the project directory using a terminal or command prompt.
3. Run the configuration script by running the following command:

```
./generate-homeserver-config.sh
```

This will generate a default configuration file for your server.

4. Start the server by running the following command:

```
docker-compose up -d
```

This will start the server in the background and you can access the application by navigating to `http://localhost:8008` in your web browser.
