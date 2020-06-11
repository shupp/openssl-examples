# openssl-examples - three tier
These examples use a three tier certificate chain - a root, an intermediate, and a leaf certificate.  You can use `make all` to create verything and then verify the leaf certificate with the bundle.  Here is just the verify target:
```
$ make verify
openssl verify -CAfile bundle.crt leaf/leaf.crt
leaf/leaf.crt: OK
```

You can also inspect the extensions to easily see the relationship of the key identifiers:
```
$ make inspect-extensions
ROOT:
        X509v3 extensions:
            X509v3 Basic Constraints: critical
                CA:TRUE, pathlen:1
            X509v3 Subject Key Identifier:
                04:50:1D:C1:26:90:F9:C0:9C:65:92:99:A2:AB:00:86:DB:40:3D:25
            X509v3 Authority Key Identifier:
                keyid:04:50:1D:C1:26:90:F9:C0:9C:65:92:99:A2:AB:00:86:DB:40:3D:25

            X509v3 Key Usage: critical
                Digital Signature, Certificate Sign, CRL Sign

INTERMEDIATE:
        X509v3 extensions:
            X509v3 Basic Constraints: critical
                CA:TRUE, pathlen:0
            X509v3 Subject Key Identifier:
                32:9C:E1:DF:0C:E0:C7:50:5A:C3:DB:F9:ED:41:71:CE:B6:BD:21:D8
            X509v3 Authority Key Identifier:
                keyid:04:50:1D:C1:26:90:F9:C0:9C:65:92:99:A2:AB:00:86:DB:40:3D:25

            X509v3 Key Usage: critical
                Digital Signature, Certificate Sign, CRL Sign

LEAF:
        X509v3 extensions:
            X509v3 Basic Constraints: critical
                CA:FALSE
            X509v3 Subject Key Identifier:
                FA:77:77:42:63:25:AF:03:5C:CD:7E:86:DC:41:EB:A8:B3:A0:FD:C9
            X509v3 Authority Key Identifier:
                keyid:32:9C:E1:DF:0C:E0:C7:50:5A:C3:DB:F9:ED:41:71:CE:B6:BD:21:D8

            X509v3 Key Usage: critical
                Digital Signature, Key Encipherment
            X509v3 Subject Alternative Name:
                DNS:www.example.org, DNS:office.example.org
```
