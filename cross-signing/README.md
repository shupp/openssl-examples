# openssl-examples - cross signing
In this example, we look at cross signing, which allows multiple certificate chains to be valid for a given leaf certificate.  For example, [LetsEncrypt](https://letsencrypt.org/certificates/#cross-signing) employed this approach to get their service into the marked as quickly as possible.  They created their own root certificate authority, but had their intermedate signed by an already established certificate authority as well so that their leaf certificates would work in existing browsers.

The idea is to have:

* Two unique root certificate authorities (CA)
* A common intermediate CA (one key, one csr)
  * This is done by having two unique intermediate certificates, each signed by a different root, but they share a common key and subject.
* Leaf certificates that validate with either root CA

Use `make all` to generate the keys and certs.  Then you can verify both bundles like so:
```
$ make verify
openssl verify -CAfile bundle-1.crt leaf/leaf.crt
leaf/leaf.crt: OK
openssl verify -CAfile bundle-2.crt leaf/leaf.crt
leaf/leaf.crt: OK
```

You can also inspect the extensions to easily see the different x509 extension values, as well as trace the key identifiers across the chains
```
$ make inspect-extensions
ROOT 1:
        X509v3 extensions:
            X509v3 Basic Constraints: critical
                CA:TRUE, pathlen:1
            X509v3 Subject Key Identifier:
                CB:90:7F:EB:20:7F:28:DE:FE:05:60:2C:FE:84:B1:D6:7A:0B:AA:06
            X509v3 Authority Key Identifier:
                keyid:CB:90:7F:EB:20:7F:28:DE:FE:05:60:2C:FE:84:B1:D6:7A:0B:AA:06

            X509v3 Key Usage: critical
                Digital Signature, Certificate Sign, CRL Sign

ROOT 2:
        X509v3 extensions:
            X509v3 Basic Constraints: critical
                CA:TRUE, pathlen:1
            X509v3 Subject Key Identifier:
                90:B0:D3:76:50:6D:10:E1:B9:03:09:11:25:54:43:7E:A5:BC:4B:F1
            X509v3 Authority Key Identifier:
                keyid:90:B0:D3:76:50:6D:10:E1:B9:03:09:11:25:54:43:7E:A5:BC:4B:F1

            X509v3 Key Usage: critical
                Digital Signature, Certificate Sign, CRL Sign

INTERMEDIATE 1:
        X509v3 extensions:
            X509v3 Basic Constraints: critical
                CA:TRUE, pathlen:0
            X509v3 Subject Key Identifier:
                1D:77:4D:BE:41:9C:EC:CB:16:08:94:B8:22:12:BA:08:D6:1B:13:96
            X509v3 Authority Key Identifier:
                keyid:CB:90:7F:EB:20:7F:28:DE:FE:05:60:2C:FE:84:B1:D6:7A:0B:AA:06

            X509v3 Key Usage: critical
                Digital Signature, Certificate Sign, CRL Sign

INTERMEDIATE 2:
        X509v3 extensions:
            X509v3 Basic Constraints: critical
                CA:TRUE, pathlen:0
            X509v3 Subject Key Identifier:
                1D:77:4D:BE:41:9C:EC:CB:16:08:94:B8:22:12:BA:08:D6:1B:13:96
            X509v3 Authority Key Identifier:
                keyid:90:B0:D3:76:50:6D:10:E1:B9:03:09:11:25:54:43:7E:A5:BC:4B:F1

            X509v3 Key Usage: critical
                Digital Signature, Certificate Sign, CRL Sign

LEAF:
        X509v3 extensions:
            X509v3 Basic Constraints: critical
                CA:FALSE
            X509v3 Subject Key Identifier:
                79:A9:FA:DF:83:47:ED:75:CA:3B:98:D2:BF:CA:BC:69:C7:04:1A:D4
            X509v3 Authority Key Identifier:
                keyid:1D:77:4D:BE:41:9C:EC:CB:16:08:94:B8:22:12:BA:08:D6:1B:13:96

            X509v3 Key Usage: critical
                Digital Signature, Key Encipherment
            X509v3 Subject Alternative Name:
                DNS:www.example.org, DNS:office.example.org
```
