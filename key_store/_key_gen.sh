#!/bin/bash
set -euo pipefail

PROJECT_DIR="${PWD}"
mkdir -p "$PROJECT_DIR"
echo "Project directory: $PROJECT_DIR"

# Passwords
PASSWORD_SERVER="Abcd1234"
PASSWORD_CLIENT="Cc123456"
PASSWORD_CA="capass"

VALID_DAYS=365

echo "=== 1. Generate Root CA (PEM + Key) ==="
openssl genrsa -out "$PROJECT_DIR/root-ca.key" 4096
openssl req -x509 -new -nodes \
  -key "$PROJECT_DIR/root-ca.key" \
  -sha256 -days $VALID_DAYS \
  -out "$PROJECT_DIR/root-ca.crt" \
  -subj "/C=MO/ST=Macao/L=Macao/O=Kaskade/OU=IT/CN=Kaskade Root CA"

# Import CA into a JKS truststore (for Java services)
keytool -importcert -trustcacerts \
  -alias root-ca \
  -file "$PROJECT_DIR/root-ca.crt" \
  -keystore "$PROJECT_DIR/ca_truststore.jks" \
  -storepass "$PASSWORD_SERVER" -noprompt

echo "=== 2. Generate Server Keystore, CSR, and Sign with CA ==="
keytool -genkeypair \
  -alias server \
  -keyalg RSA -keysize 2048 -validity $VALID_DAYS \
  -dname "CN=localhost,OU=IT,O=Kaskade,L=Macao,ST=Macao,C=MO" \
  -keystore "$PROJECT_DIR/server_keystore.jks" \
  -storepass "$PASSWORD_SERVER" -keypass "$PASSWORD_SERVER"

keytool -certreq \
  -alias server \
  -keystore "$PROJECT_DIR/server_keystore.jks" \
  -storepass "$PASSWORD_SERVER" \
  -file "$PROJECT_DIR/server.csr"

openssl x509 -req \
  -in "$PROJECT_DIR/server.csr" \
  -CA "$PROJECT_DIR/root-ca.crt" \
  -CAkey "$PROJECT_DIR/root-ca.key" \
  -CAcreateserial \
  -out "$PROJECT_DIR/server.crt" \
  -days $VALID_DAYS -sha256 \
  -extfile <(echo "subjectAltName=DNS:localhost,IP:127.0.0.1")

# Import CA and signed server cert into keystore
keytool -importcert -trustcacerts \
  -alias root-ca \
  -file "$PROJECT_DIR/root-ca.crt" \
  -keystore "$PROJECT_DIR/server_keystore.jks" \
  -storepass "$PASSWORD_SERVER" -noprompt

keytool -importcert \
  -alias server \
  -file "$PROJECT_DIR/server.crt" \
  -keystore "$PROJECT_DIR/server_keystore.jks" \
  -storepass "$PASSWORD_SERVER" -noprompt

# Server truststore (trust CA)
cp "$PROJECT_DIR/ca_truststore.jks" "$PROJECT_DIR/server_truststore.jks"

echo "=== 3. Generate Client Keystore, CSR, and Sign with CA ==="
keytool -genkeypair \
  -alias client \
  -keyalg RSA -keysize 2048 -validity $VALID_DAYS \
  -dname "CN=client,OU=IT,O=Kaskade,L=Macao,ST=Macao,C=MO" \
  -keystore "$PROJECT_DIR/client_keystore.jks" \
  -storepass "$PASSWORD_CLIENT" -keypass "$PASSWORD_CLIENT"

keytool -certreq \
  -alias client \
  -keystore "$PROJECT_DIR/client_keystore.jks" \
  -storepass "$PASSWORD_CLIENT" \
  -file "$PROJECT_DIR/client.csr"

openssl x509 -req \
  -in "$PROJECT_DIR/client.csr" \
  -CA "$PROJECT_DIR/root-ca.crt" \
  -CAkey "$PROJECT_DIR/root-ca.key" \
  -CAcreateserial \
  -out "$PROJECT_DIR/client.crt" \
  -days $VALID_DAYS -sha256

# Import CA and signed client cert into client keystore
keytool -importcert -trustcacerts \
  -alias root-ca \
  -file "$PROJECT_DIR/root-ca.crt" \
  -keystore "$PROJECT_DIR/client_keystore.jks" \
  -storepass "$PASSWORD_CLIENT" -noprompt

keytool -importcert \
  -alias client \
  -file "$PROJECT_DIR/client.crt" \
  -keystore "$PROJECT_DIR/client_keystore.jks" \
  -storepass "$PASSWORD_CLIENT" -noprompt

# Client truststore (trust CA)
cp "$PROJECT_DIR/ca_truststore.jks" "$PROJECT_DIR/client_truststore.jks"

echo "=== 4. Export PEM Versions for curl/OpenSSL ==="
# Server private key
keytool -importkeystore \
  -srckeystore "$PROJECT_DIR/server_keystore.jks" \
  -srcstorepass "$PASSWORD_SERVER" \
  -destkeystore "$PROJECT_DIR/server.p12" \
  -deststoretype PKCS12 -deststorepass "$PASSWORD_SERVER"

openssl pkcs12 -in "$PROJECT_DIR/server.p12" -nodes \
  -nocerts -out "$PROJECT_DIR/server.key" \
  -passin pass:"$PASSWORD_SERVER"

# Client private key
keytool -importkeystore \
  -srckeystore "$PROJECT_DIR/client_keystore.jks" \
  -srcstorepass "$PASSWORD_CLIENT" \
  -destkeystore "$PROJECT_DIR/client.p12" \
  -deststoretype PKCS12 -deststorepass "$PASSWORD_CLIENT"

openssl pkcs12 -in "$PROJECT_DIR/client.p12" -nodes \
  -nocerts -out "$PROJECT_DIR/client.key" \
  -passin pass:"$PASSWORD_CLIENT"

echo "=== Done. Key store & certs ready in $PROJECT_DIR ==="

