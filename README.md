
# Dockerized PQC mTLS Auditbeat and Logstash Testbed

## 1. Prerequisites

- Docker and Docker Compose
- `openquantumsafe/oqs-ossl3` image for certificate generation
- `dockurr/stunnel` image for PQC TLS transport
- Auditbeat and Logstash images


Create networks
```bash 
docker network create pqc-net log-net beat-net
```

## 2. Generate PQC Cerificates
Run once initially, or whenever certificates need to be regenerated.
```bash
docker run --rm \
  --entrypoint /bin/sh \
  -v "$PWD/init-certs.sh:/init-certs.sh:ro" \
  -v "$PWD/certs:/certs" \
  openquantumsafe/oqs-ossl3:latest \
  /init-certs.sh
```