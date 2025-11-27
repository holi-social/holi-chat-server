FROM europe-north1-docker.pkg.dev/holi-shared/docker-hub-remote/matrixdotorg/sygnal:v0.15.1

RUN apt-get update && apt-get upgrade -y && apt-get install -y gettext-base

COPY data-push-gateway/sygnal.yaml.template /data/sygnal.yaml.template
COPY generate-push-gateway-config.sh /generate-push-gateway-config.sh
RUN chmod +x /generate-push-gateway-config.sh

COPY start-push-gateway.sh /start-push-gateway.sh

ENTRYPOINT [ "/start-push-gateway.sh" ]
