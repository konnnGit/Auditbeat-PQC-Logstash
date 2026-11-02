
# Dockerized PQC mTLS Between Auditbeat and Logstash Testbed

## 1. Prerequisites

- Docker and Docker Compose
- `openquantumsafe/oqs-ossl3` image for certificate generation
- `dockurr/stunnel` image for PQC TLS transport
- Auditbeat and Logstash images


Create networks
```bash 
docker network create pqc-net log-net beat-net
```
The log/beat  are local nets for logstash and auditbeat, respectively, and the pqc-net is the public one.
## 2. Generate PQC Cerificates
Run once initially, or whenever certificates need to be regenerated. The bash script generates the CA, client, and server certificates and private keys in certs/. In case alternative DSA should be tested, change the paremeter of the field 
 ```bash 
 -newkey mldsa44
 ``` 
 , existing in the script. In case that alternative KEM should be tested, the appropriate value
  ```bash 
  curves = MLKEM768
  ```
  , in stunnel .conf files, should be changed. For the supported ssl1.3 PQC DSA & KEM algorithms refer to https://github.com/open-quantum-safe/oqs-provider. 

```bash
cd ~/
```
```bash
git clone https://github.com/konnnGit/Auditbeat-PQC-Logstash.git
```
```bash
cd ~/Auditbeat-PQC-Logstash/certs/
```
```bash
docker run --rm \
  --entrypoint /bin/sh \
  -v "$PWD/init-certs.sh:/init-certs.sh:ro" \
  -v "$PWD/certs:/certs" \
  openquantumsafe/oqs-ossl3:latest \
  /init-certs.sh
```

## 3. Start the system
The Compose file creates and configures:
- auditbeat
- pqc-stunnel-client
- pqc-stunnel-server
- logstash
```bash
cd ~/Auditbeat-PQC-Logstash/
```
```bash
docker compose up -d
```
After system boots, verify that logstash receives auditbeat events:
```bash
docker compose logs -f logstash
```
As depicted in the following picture, during the handshake the MLKEM was negotiated.
![pic][mlkem.png]
