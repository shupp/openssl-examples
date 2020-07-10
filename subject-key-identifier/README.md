# openssl-examples - subject key identifier
This example shows how you can manually generate a [Subject Key Identifier](https://tools.ietf.org/html/rfc5280#section-4.2.1.2) from a public key. A key can be extracted from an x509 certificate, or from a private key.

To build your key and cert, run `make prep`.  Then, you can run `make` to see all the available targets:

```
$ make
Available targets:

all
clean
generate-ski-from-cert
generate-ski-from-private-key
help
inspect-root
inspect-root-extensions
parse-ski-from-pubkey-input
prep
root/ca.crt
root/ca.key
```

To compare the Subject Key Identifiers in the x509V3 extension, as well as manually generated from the public key in the cert as well as the public key extracted from the private key, run `make all`:

```
$ make all
Inspecting x509v3 Extensions from the Cert:
        X509v3 extensions:
            X509v3 Basic Constraints: critical
                CA:TRUE, pathlen:1
            X509v3 Subject Key Identifier:
                5D:1F:06:E6:8B:B8:25:98:C5:E7:8F:5A:59:83:58:3D:49:58:CF:18
            X509v3 Authority Key Identifier:
                keyid:5D:1F:06:E6:8B:B8:25:98:C5:E7:8F:5A:59:83:58:3D:49:58:CF:18

            X509v3 Key Usage: critical
                Digital Signature, Certificate Sign, CRL Sign

Generated Subject Key Identifier from Cert:
5D:1F:06:E6:8B:B8:25:98:C5:E7:8F:5A:59:83:58:3D:49:58:CF:18

Generated Subject Key Identifier from Private Key:
5D:1F:06:E6:8B:B8:25:98:C5:E7:8F:5A:59:83:58:3D:49:58:CF:18
```

Though the commands called by `make` are hidden for cleaner output, here's the general idea of how the Subject Key Identifier is created, which you should be able to paste into a shell script and run:

```
#!/bin/bash

TEMP=$(mktemp)
openssl x509 -pubkey -in root/ca.crt \
    | openssl asn1parse -strparse 19 -out ${TEMP} >/dev/null
openssl dgst -c -sha1 ${TEMP} \
    | awk '{ print $2 }' \
    | tr '[:lower:]' '[:upper:]'
rm -f ${TEMP}
```
