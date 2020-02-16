# Always pin versions

FROM alpine:3.11.3

ENV TERRAFORM_VERSION=0.12.20 \
    KUBE_LATEST_VERSION=v1.17.0 \
    AZURE_CLI_VERSION=2.0.81

RUN apk --update --no-cache add bash ca-certificates curl jq openssl openssh-client py-pip && \
    apk add --virtual=build --no-cache gcc libffi-dev musl-dev openssl-dev python-dev make gettext && \
    wget -O terraform.zip "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" && \
  unzip terraform.zip -d /bin && \
  curl -L https://storage.googleapis.com/kubernetes-release/release/${KUBE_LATEST_VERSION}/bin/linux/amd64/kubectl -o /usr/local/bin/kubectl && \
  chmod +x /usr/local/bin/kubectl && \
  pip --no-cache-dir install -U pip && \
  pip --no-cache-dir install azure-cli==${AZURE_CLI_VERSION} && \
  addgroup -S demo && \
  adduser -S demo -g demo && \
  apk del --purge build && \
  mkdir -p /code && \
  chown -R demo:demo /code && \
  rm -rf terraform.zip /var/cache/apk/* /tmp/*

WORKDIR /code

USER demo

ENV CLI_COLOR=1 \
    PS1='\[\033[01;34m\]\\$\[\033[00m\] '