# Always pin versions

FROM alpine:3.11.3

ENV TERRAFORM_VERSION=0.12.20 \
    KUBE_LATEST_VERSION=v1.17.3 \
    AZURE_CLI_VERSION=2.0.81

RUN apk --update --no-cache add ca-certificates openssl curl py-pip bash && \
    apk add --virtual=build --no-cache gcc libffi-dev musl-dev openssl-dev python-dev make gettext && \
    wget -O terraform.zip "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" && \
  unzip terraform.zip -d /bin && \
  curl -L https://storage.googleapis.com/kubernetes-release/release/${KUBE_LATEST_VERSION}/bin/linux/amd64/kubectl -o /usr/local/bin/kubectl && \
  chmod +x /usr/local/bin/kubectl && \
  pip --no-cache-dir install -U pip && \
  pip --no-cache-dir install azure-cli==${AZURE_CLI_VERSION} && \
  apk del --purge build && \
  addgroup -S demo && \
  adduser -S demo -G demo && \
  mkdir -p /code && \
  mkdir -p /home/demo && \
  chown -R demo:demo /code && \
  rm -rf terraform.zip /var/cache/apk/* /tmp/*

WORKDIR /code

# More usable shell prompt
COPY ./etc/profile /etc/profile

USER demo