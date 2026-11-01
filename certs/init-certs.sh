
#!/bin/sh
set -eu

# 1. Root CA
openssl req -x509 -new \
    -newkey mldsa44   \
    -noenc \
    -keyout CA.key \
    -out CA.crt \
    -subj "/CN=PQC-Root-CA" \
   

# 2. Client key and CSR
openssl req -new \
    -newkey mldsa44   \
    -noenc \
    -keyout client.key \
    -out client.csr \
    -subj "/CN=pqc-client"

# Sign client certificate
openssl x509 -req \
    -in client.csr \
    -CA CA.crt \
    -CAkey CA.key \
    -CAcreateserial \
    -out client.crt \
    

# 3. Server key and CSR
openssl req -new \
    -newkey mldsa44   \
    -noenc \
    -keyout server.key \
    -out server.csr \
    -subj "/CN=pqc-server"


# Sign server certificate
openssl x509 -req \
    -in server.csr \
    -CA CA.crt \
    -CAkey CA.key \
    -CAcreateserial \
    -out server.crt \

# 4. Verify certificates
#openssl verify -CAfile CA.crt -purpose sslclient client.crt
#openssl verify -CAfile CA.crt -purpose sslserver \
#    -verify_hostname pqc-server server.crt

chmod 600 CA.key client.key server.key

echo "Finished"
