FROM matrixdotorg/sygnal

RUN apt-get update && apt-get install -y gettext-base

COPY sygnal.yaml.template /sygnal.yaml.template
COPY generate-push-gateway-config.sh /generate-push-gateway-config.sh
RUN chmod +x /generate-push-gateway-config.sh

COPY start-push-gateway.sh /start-push-gateway.sh

ENTRYPOINT [ "/start-push-gateway.sh" ]
