mkdir registryone

export REGISTRYONE_FQDN='registryone'
export REGISTRYONE_BASE="registryone"

echo "this is registry base ${REGISTRYONE_BASE}"
echo "this is registry fqdn ${REGISTRYONE_FQDN}"
echo ''
echo ''
sleep 2

mkdir  ${REGISTRYONE_BASE}/{auth,certs,data,downloads}
sleep 3
mkdir ${REGISTRYONE_BASE}/downloads/{images,tools,secrets}
sleep 2
echo "created ${REGISTRYONE_BASE}/{auth,certs,data,downloads}" 
echo "created ${REGISTRYONE_BASE}/downloads/{images,tools,secrets}"
echo ''
echo '' 
touch ${REGISTRYONE_BASE}/answerFile.txt
echo "im here answerFile" > ${REGISTRYONE_BASE}/answerFile.txt
echo ''
echo ''
cat ${REGISTRYONE_BASE}/answerFile.txt
## Add the registry FQDN to /etc/hosts
echo "127.0.0.1      ${REGISTRYONE_FQDN}"
echo "127.0.0.1      ${REGISTRYONE_FQDN}" >> /etc/hosts
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
CN=${REGISTRYONE_FQDN}
[ req_ext ]
subjectAltName = @alt_names
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid:always,issuer
basicConstraints = critical, CA:true
keyUsage = critical, digitalSignature, cRLSign, keyCertSign
[ alt_names ]
DNS.1 = ${REGISTRYONE_FQDN}" > ${REGISTRYONE_BASE}/certs/answerFile.txt
sleep 3
cat ${REGISTRYONE_BASE}/certs/answerFile.txt
sleep 3
echo ''
echo ''
openssl req -newkey rsa:4096 -nodes -sha256 -keyout ${REGISTRYONE_BASE}/certs/domainone.key -x509 -days 365 -out ${REGISTRYONE_BASE}/certs/domainone.crt -config <( cat ${REGISTRYONE_BASE}/certs/answerFile.txt )
cp ${REGISTRYONE_BASE}/certs/domainone.crt /etc/pki/ca-trust/source/anchors/
sleep 2
update-ca-trust extract
echo ''
echo ''
## Create username and password to authenticate with the registry
htpasswd -bBc ${REGISTRYONE_BASE}/auth/htpasswd admin redhat
echo "Created username and password to authenticate with the registry"
echo "admin:redhat"
## Open the used port to allow pulling from the registry
echo ''
echo ''
echo " if you need do this mnually:"
echo "systemctl start firewalld
firewall-cmd --add-port=5000/tcp --zone=public --permanent
firewall-cmd --reload"
echo "to Enabled traffic on port 5000 to be used by the registry."
echo ''
echo ''
## Create the registry:
echo "------------------------------------------"
echo "now to create registry, this is the command:"
echo "podman run --name ${REGISTRYONE_FQDN} --rm -d -p 5000:5000 \
        -v ./${REGISTRYONE_BASE}/data:/var/lib/registry:z \
        -v ./${REGISTRYONE_BASE}/auth:/auth:z -e "REGISTRY_AUTH=htpasswd" \
        -e "REGISTRY_AUTH_HTPASSWD_REALM=Registry" \
        -e "REGISTRY_HTTP_SECRET=ALongRandomSecretForRegistry" \
        -e REGISTRY_AUTH_HTPASSWD_PATH=/auth/htpasswd \
        -v ./${REGISTRYONE_BASE}/certs:/certs:z \
        -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/domainone.crt \
        -e REGISTRY_HTTP_TLS_KEY=/certs/domainone.key \
docker.io/library/registry:2"

echo "-------------------------"
echo ''
echo ''
echo "podman run --name ${REGISTRYONE_FQDN} --rm -d -p 5000:5000 \
        -v ./${REGISTRYONE_BASE}/data:/var/lib/registry:z \
        -v ./${REGISTRYONE_BASE}/auth:/auth:z -e "REGISTRY_AUTH=htpasswd" \
        -e "REGISTRY_AUTH_HTPASSWD_REALM=Registry" \
        -e "REGISTRY_HTTP_SECRET=ALongRandomSecretForRegistry" \
        -e REGISTRY_AUTH_HTPASSWD_PATH=/auth/htpasswd \
        -v ./${REGISTRYONE_BASE}/certs:/certs:z \
        -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/domainone.crt \
        -e REGISTRY_HTTP_TLS_KEY=/certs/domainone.key \
docker.io/library/registry:2" > ${REGISTRYONE_BASE}/downloads/tools/start_registry.sh
sleep 3
chmod a+x ${REGISTRYONE_BASE}/downloads/tools/start_registry.sh
${REGISTRYONE_BASE}/downloads/tools/start_registry.sh
sleep 5
echo ''
curl -u admin:redhat -k https://${REGISTRYONE_FQDN}:5000/v2/_catalog
echo ''
echo ''
echo 'The script needs to return {"repositories":[]}, if everything worked.'
