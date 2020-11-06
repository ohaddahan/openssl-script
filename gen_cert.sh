#!/bin/bash
 
export OUTDIR="CERT"
rm -fvr ${OUTDIR}
mkdir -p ${OUTDIR}
 
export CNF="${OUTDIR}/openssl.cnf"
export KEY="${OUTDIR}/my.key"
export CERT="${OUTDIR}/my.csr"
export SIGN_CERT="${OUTDIR}/my.csr.sign"
export OUT="${OUTDIR}/server.crt"
 
 
rm -fvr ${CNF}
rm -fvr ${KEY}
rm -fvr ${CERT}
rm -fvr ${OUT}
rm -fvr ${OUT}.text
 
cat > ${CNF} <<- EOM
[req]
distinguished_name = req_distinguished_name
req_extensions = v3_req
 
[req_distinguished_name]
countryName = Country Name (2 letter code)
countryName_default = US
stateOrProvinceName = State or Province Name (full name)
stateOrProvinceName_default = MN
localityName = Locality Name (eg, city)
localityName_default = Minneapolis
organizationalUnitName  = Organizational Unit Name (eg, section)
organizationalUnitName_default  = Domain Control Validated
commonName = Internet Widgits Ltd
commonName_max  = 64
 
[ v3_req ]
# Extensions to add to a certificate request
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = @alt_names
[alt_names]
DNS.1 = `hostname`
DNS.2 = `hostname -f`
EOM
 
 
set -x
 
openssl genrsa -out ${KEY} 4096
openssl req -new -out ${CERT} -key ${KEY} -config ${CNF} -extensions v3_req
openssl req -text -noout -in ${CERT} > ${CERT}.text       
openssl x509 -req -days 3650 -in ${CERT} -signkey ${KEY} -out ${SIGN_CERT} -extfile ${CNF} -extensions v3_req
cat ${KEY} ${SIGN_CERT} > ${OUT}
