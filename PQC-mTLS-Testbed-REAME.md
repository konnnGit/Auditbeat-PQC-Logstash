
# 1. CREATE CERTS
# This part is used once the certs must be created. 

# Create CA cert using init-certs.sh
cd ~/labs/oqs-ossl3/certs

docker run --rm \
  --entrypoint /bin/sh \
  -v "$PWD/init-certs.sh:/init-certs.sh:ro" \
  -v "$PWD/certs:/certs" \
  openquantumsafe/oqs-ossl3:latest \
  init-certs.sh

# 2. CREATE CLIENT/SERVER DOCKER SERVICES
# This part is initiated once, at the very beggining, after the 1. CREATE CERTS. 
# It create client/server services and associate them with the correspoding certs.
# If alternative DSA must be used by executing # 1. CREATE CERTS again, it is not nessacery to create these docker sevices again, so move step 3.

# Create a client container, associate with keys, and connect to the  pqc-net network
docker run -dit \
  --name pqc-client \
  --network pqc-net \
  --entrypoint /bin/sh \
  -v "$PWD/certs/CA.crt:/certs/CA.crt:ro" \
  -v "$PWD/certs/client.crt:/certs/client.crt:ro" \
  -v "$PWD/certs/client.key:/certs/client.key:ro" \
  openquantumsafe/oqs-ossl3:latest \
  -c "while true; do sleep 3600; done"

# Create a server container, associate with keys, and connect to the  pqc-net network
docker run -dit \
  --name pqc-server \
  --network pqc-net \
  --entrypoint /bin/sh \
  -v "$PWD/certs/CA.crt:/certs/CA.crt:ro" \
  -v "$PWD/certs/server.crt:/certs/server.crt:ro" \
  -v "$PWD/certs/server.key:/certs/server.key:ro" \
  openquantumsafe/oqs-ossl3:latest \
  -c "while true; do sleep 3600; done"


# 3. START THE SYSTEM
docker compose up -d


# 3. START PQC mTLS 

# Start server
docker exec -it pqc-server openssl s_server \
  -accept 4433 \
  -tls1_3 \
  -groups mlkem512 \
  -cert /certs/server.crt \
  -key /certs/server.key \
  -CAfile /certs/CA.crt \
  -brief
  -Verify 1

# Start client
docker exec -it pqc-client openssl s_client \
  -connect pqc-server:4433 \
  -tls1_3 \
  -groups mlkem512 \
  -cert /certs/client.crt \
  -key /certs/client.key \
  -CAfile /certs/CA.crt \
  -verify_return_error \
  -verify_hostname pqc-server

# 4. CREATE CLIENT/SERVER STUNNEL DOCKERS
# These dockers will be the interface between local networks and public PQC network (i.e auditbeat ---beat-net---> client-stunnel ---pqc-net ---> server-stunnel ---log-net---> logstash). The 