# Dockerized PQC mTLS Testbed

### 1. Prerequisites
#### -Docker and Docker Compose
#### -openquantumsafe/oqs-ossl3 image for certificate generation
#### -dockurr/stunnel image for PQC TLS transport
#### -Auditbeat and Logstash 9.2.0
#### -Existing configuration files in certs/, stunnel/, auditbeat/, and logstash/pipeline/

#### Create networks
```bash
docker network create pqc-net log-net beat-net
```