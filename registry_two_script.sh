mkdir registrytwo

export REGISTRYTWO_FQDN='registrytwo'
export REGISTRYTWO_BASE="registrytwo"

echo "this is registry base ${REGISTRYTWO_BASE}"
echo "this is registry fqdn ${REGISTRYTWO_FQDN}"
echo ''
echo ''
sleep 2

mkdir  ${REGISTRYTWO_BASE}/{auth,certs,data,downloads}
sleep 3
mkdir ${REGISTRYTWO_BASE}/downloads/{images,tools,secrets}
sleep 2
echo "created ${REGISTRYTWO_BASE}/{auth,certs,data,downloads}" 
echo "created ${REGISTRYTWO_BASE}/downloads/{images,tools,secrets}"
echo ''
echo '' 
touch ${REGISTRYTWO_BASE}/answerFile.txt
echo "im here answerFile" > ${REGISTRYTWO_BASE}/answerFile.txt
echo ''
echo ''
cat ${REGISTRYTWO_BASE}/answerFile.txt
## Add the registry FQDN to /etc/hosts
echo "127.0.0.1      ${REGISTRYTWO_FQDN}"
echo "127.0.0.1      ${REGISTRYTWO_FQDN}" >> /etc/hosts
echo "Added the registry FQDN to /etc/hosts"
## Install necessary dependencies.
echo ''
echo ''
echo "now to create the self certificate:"
echo ''
echo " [req]
default_bits = 4096
prompt = no
default_md = sha256
x509_extensions = req_ext
req_extensions = req_ext
distinguished_name = dn
[ dn ]
C=US
ST=New York
L=New York
O=MyOrg
OU=MyOU
emailAddress=me@working.me
CN=${REGISTRYTWO_FQDN}
[ req_ext ]
subjectAltName = @alt_names
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid:always,issuer
basicConstraints = critical, CA:true
keyUsage = critical, digitalSignature, cRLSign, keyCertSign
[ alt_names ]
DNS.1 = ${REGISTRYTWO_FQDN}" > ${REGISTRYTWO_BASE}/certs/answerFile.txt
sleep 3
cat ${REGISTRYTWO_BASE}/certs/answerFile.txt
sleep 3
echo ''
echo ''
openssl req -newkey rsa:4096 -nodes -sha256 -keyout ${REGISTRYTWO_BASE}/certs/domaintwo.key -x509 -days 365 -out ${REGISTRYTWO_BASE}/certs/domaintwo.crt -config <( cat ${REGISTRYTWO_BASE}/certs/answerFile.txt )
cp ${REGISTRYTWO_BASE}/certs/domaintwo.crt /etc/pki/ca-trust/source/anchors/
sleep 2
update-ca-trust extract
echo ''
echo ''
## Create username and password to authenticate with the registry
htpasswd -bBc ${REGISTRYTWO_BASE}/auth/htpasswd admin redhat
echo "Created username and password to authenticate with the registry"
echo "admin:redhat"
## Open the used port to allow pulling from the registry
echo ''
echo ''
echo " if you need do this mnually:"
echo "systemctl start firewalld
firewall-cmd --add-port=5001/tcp --zone=public --permanent
firewall-cmd --reload"
echo "to Enabled traffic on port 5001 to be used by the registry."
echo ''
echo ''
## Create the registry:
echo "------------------------------------------"
echo "now to create registry, this is the command:"
echo "podman run --name ${REGISTRYTWO_FQDN} --rm -d -p 5001:5000 \
        -v ./${REGISTRYTWO_BASE}/data:/var/lib/registry:z \
        -v ./${REGISTRYTWO_BASE}/auth:/auth:z -e "REGISTRY_AUTH=htpasswd" \
        -e "REGISTRY_AUTH_HTPASSWD_REALM=Registry" \
        -e "REGISTRY_HTTP_SECRET=ALongRandomSecretForRegistry" \
        -e REGISTRY_AUTH_HTPASSWD_PATH=/auth/htpasswd \
        -v ./${REGISTRYTWO_BASE}/certs:/certs:z \
        -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/domaintwo.crt \
        -e REGISTRY_HTTP_TLS_KEY=/certs/domaintwo.key \
docker.io/library/registry:2"

echo "-------------------------"
echo ''
echo ''
echo "podman run --name ${REGISTRYTWO_FQDN} --rm -d -p 5001:5000 \
        -v ./${REGISTRYTWO_BASE}/data:/var/lib/registry:z \
        -v ./${REGISTRYTWO_BASE}/auth:/auth:z -e "REGISTRY_AUTH=htpasswd" \
        -e "REGISTRY_AUTH_HTPASSWD_REALM=Registry" \
        -e "REGISTRY_HTTP_SECRET=ALongRandomSecretForRegistry" \
        -e REGISTRY_AUTH_HTPASSWD_PATH=/auth/htpasswd \
        -v ./${REGISTRYTWO_BASE}/certs:/certs:z \
        -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/domaintwo.crt \
        -e REGISTRY_HTTP_TLS_KEY=/certs/domaintwo.key \
docker.io/library/registry:2" > ${REGISTRYTWO_BASE}/downloads/tools/start_registry.sh
sleep 3
chmod a+x ${REGISTRYTWO_BASE}/downloads/tools/start_registry.sh
${REGISTRYTWO_BASE}/downloads/tools/start_registry.sh
sleep 5
echo ''
curl -u admin:redhat -k https://${REGISTRYTWO_FQDN}:5001/v2/_catalog
echo ''
echo ''
echo 'The script needs to return {"repositories":[]}, if everything worked.'
