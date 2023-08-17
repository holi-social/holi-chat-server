FROM gitlab.holi.team:5050/app/holi-chat-server/sygnal_pushkey_fix:latest

RUN apt-get update && apt-get install -y gettext-base

COPY data /data
COPY start.sh /start.sh

RUN chmod +x /start.sh

ENTRYPOINT [ "/start.sh" ]
