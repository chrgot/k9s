# -----------------------------------------------------------------------------
# The base image for building the k9s binary

FROM golang:1.19.0-buster AS build

WORKDIR /k9s
COPY go.mod go.sum main.go Makefile ./
COPY internal internal
COPY cmd cmd
RUN apt-get install make git gcc libc-dev curl -y && make build

# -----------------------------------------------------------------------------
# Build the final Docker image

FROM debian:buster
ARG KUBECTL_VERSION="v1.24.3"

COPY --from=build /k9s/execs/k9s /bin/k9s
RUN apt-get update && apt-get install curl vim -y \
  && curl -L https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl -o /usr/local/bin/kubectl \
  && chmod +x /usr/local/bin/kubectl 
  
  
#https://cloud.google.com/sdk/docs/install#deb

RUN apt-get install apt-transport-https ca-certificates gnupg -y
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list \
  && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg  add - \
  && apt-get update -y && apt-get install google-cloud-cli google-cloud-sdk-gke-gcloud-auth-plugin -y
 

ADD entrypoint.sh /
RUN chmod +x /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]