FROM gitlab.holi.team:5050/app/holi-chat-server/sygnal_pushkey_fix:latest

RUN apt-get update && apt-get upgrade -y && apt-get install -y gettext-base

COPY data-push-gateway/sygnal.yaml.template /data/sygnal.yaml.template
COPY generate-push-gateway-config.sh /generate-push-gateway-config.sh
RUN chmod +x /generate-push-gateway-config.sh

COPY start-push-gateway.sh /start-push-gateway.sh

ENTRYPOINT [ "/start-push-gateway.sh" ]
