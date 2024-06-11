FROM matrixdotorg/synapse

RUN apt-get update && apt-get upgrade -y && apt-get install -y gettext-base

COPY data /data
COPY start.sh /start.sh

RUN chmod +x /start.sh

ENTRYPOINT [ "/start.sh" ]
