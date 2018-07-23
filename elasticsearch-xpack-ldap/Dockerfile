FROM elasticsearch
LABEL maintainer="Prasanjit Singh | nixgurus@gmail.com"
RUN apt-get update -y
RUN apt-get install vim -y
COPY elasticsearch.yml role_mapping.yml /usr/share/elasticsearch/config/
RUN /usr/share/elasticsearch/bin/elasticsearch-plugin install x-pack
