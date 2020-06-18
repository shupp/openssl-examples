# openssl-examples - crl

Here is a basic example of creating a [Certificate Revocation List](https://en.wikipedia.org/wiki/Certificate_revocation_list).  To get started, you can run `make prep` to generate the initial root certificate authority, one leaf certificate, and another leaf certificate to be revoked.

Once that's done, have a look have a look at the empty CRL, and note that the x509v3 CRL Number is `0`:

```
$ make inspect-crl
openssl crl -text -noout -in crl/crl.pem
Certificate Revocation List (CRL):
        Version 2 (0x1)
    Signature Algorithm: sha256WithRSAEncryption
        Issuer: /C=US/ST=California/L=San Francisco/OU=Operations/CN=Fake Root CA/emailAddress=fakeroot@example.org
        Last Update: Jun 18 21:00:46 2020 GMT
        Next Update: Jun 18 21:00:46 2021 GMT
        CRL extensions:
            X509v3 CRL Number:
                0
No Revoked Certificates.
    Signature Algorithm: sha256WithRSAEncryption
         96:93:6c:d4:30:69:be:1a:0b:c8:e6:d6:4c:e1:fd:fe:cf:27:
         7f:c0:1e:00:60:0b:02:c6:94:1c:31:79:28:07:92:60:fd:6d:
         b7:cb:3f:a8:1c:61:4c:95:16:05:bc:a1:4c:ba:0b:03:f9:32:
         17:1f:d1:78:a5:d8:94:93:bc:d2:d6:1e:85:bd:6d:25:cf:40:
         43:96:89:8f:d0:f6:40:83:33:e7:f2:f6:de:13:ff:71:3f:23:
         98:97:1d:af:84:bf:81:de:a4:f5:f8:a0:4b:c6:f4:c8:8a:ec:
         a8:e3:02:4e:25:9e:e6:bf:fc:23:80:47:29:44:b2:0c:71:cd:
         9b:5a:25:c7:a5:70:b0:e0:74:32:a6:1e:74:b9:39:71:ae:70:
         58:4f:27:a4:77:58:7a:c0:7c:1a:16:a1:d1:79:1e:0c:9d:c5:
         89:90:4f:5e:00:f4:3e:c5:6a:ca:86:86:87:2c:27:9a:21:15:
         76:c0:db:a0:f9:ba:ad:7f:07:60:f9:65:fa:69:f9:af:6c:19:
         9d:95:a7:32:d2:a4:a6:a9:57:f9:95:58:32:d8:c4:99:b8:a0:
         c4:8f:78:48:d5:63:0c:4d:ee:bf:b8:a5:62:f2:9f:4a:97:2e:
         c5:75:1e:b1:6e:3a:27:fc:dd:eb:42:54:d3:a4:a0:dc:73:13:
         fb:cd:17:b6
```

Now, let's verify that both certificates are valid and not on the CRL:

```
$ make check-leaf-crl
cat root/ca.crt crl/crl.pem > crl/bundle.pem
openssl verify -extended_crl -verbose -CAfile crl/bundle.pem -crl_check leaf/leaf.crt
leaf/leaf.crt: OK
$ make check-leaf-revoked-crl
cat root/ca.crt crl/crl.pem > crl/bundle.pem
openssl verify -extended_crl -verbose -CAfile crl/bundle.pem -crl_check leaf-revoked/leaf.crt
leaf-revoked/leaf.crt: OK
```

Next, we can revoke a certificate using the reason of "Key Compromise":

```
$ make revoke
openssl ca -revoke leaf-revoked/leaf.crt -keyfile root/ca.key -cert root/ca.crt -config crl/crl.conf -crl_reason keyCompromise
Using configuration from crl/crl.conf
Adding Entry with serial number D2A2A96C6F6E35A4 to DB for /C=US/ST=California/L=San Francisco/OU=My Example Website 2/CN=www2.example.org/emailAddress=user@example.org
Revoking Certificate D2A2A96C6F6E35A4.
Data Base Updated
openssl ca -gencrl -keyfile root/ca.key -cert root/ca.crt -out crl/crl.pem -config crl/crl.conf
Using configuration from crl/crl.conf
```

If we inspect the CRL now, you'll see the revoked cert and that the x509v3 CRL number has incremented to `1`:

```
$ make inspect-crl
openssl crl -text -noout -in crl/crl.pem
Certificate Revocation List (CRL):
        Version 2 (0x1)
    Signature Algorithm: sha256WithRSAEncryption
        Issuer: /C=US/ST=California/L=San Francisco/OU=Operations/CN=Fake Root CA/emailAddress=fakeroot@example.org
        Last Update: Jun 18 21:01:33 2020 GMT
        Next Update: Jun 18 21:01:33 2021 GMT
        CRL extensions:
            X509v3 CRL Number:
                1
Revoked Certificates:
    Serial Number: D2A2A96C6F6E35A4
        Revocation Date: Jun 18 21:01:33 2020 GMT
        CRL entry extensions:
            X509v3 CRL Reason Code:
                Key Compromise
    Signature Algorithm: sha256WithRSAEncryption
         09:a8:c4:90:d1:c1:77:1f:fb:8c:69:d3:49:8c:37:bc:37:fe:
         8e:65:3e:08:26:4d:75:d8:73:68:a7:3f:67:f0:75:86:05:8a:
         70:19:58:15:c4:d9:a1:b1:ab:99:62:b7:76:d7:30:87:dd:3e:
         03:82:d1:c4:a5:b7:6a:ae:6a:e0:2b:18:5c:9e:88:78:90:b6:
         0d:8c:b3:ec:f9:49:bb:29:75:10:47:72:a1:dd:7b:ea:28:07:
         83:e2:be:ae:dc:cd:58:b3:9c:6f:81:4a:36:38:69:11:ea:8d:
         77:f1:57:7d:1d:56:0e:05:0c:d2:e2:da:8a:c7:23:1f:13:4b:
         84:3c:50:32:2d:0e:74:6a:10:13:8e:72:68:c2:c6:db:45:fd:
         74:a4:d8:0f:00:c8:9e:fb:7d:35:49:a4:b7:5a:49:55:26:84:
         e7:b3:55:53:d3:6f:b8:5e:0f:1d:19:fe:ca:f0:40:2b:ee:06:
         d9:a9:66:9f:d6:63:96:69:a0:d3:cd:09:b1:a2:08:df:01:8f:
         3b:7e:86:b7:07:c5:f5:ce:24:bf:fe:4f:21:b0:4d:95:85:c3:
         cf:be:b6:3e:a5:4c:40:9c:8a:37:f3:25:2d:32:3e:4d:e8:a9:
         f2:58:f9:0e:3d:88:8e:31:1a:41:91:d5:fc:45:39:f3:15:ea:
         eb:02:35:7d
```

Also, the we can see that checking the revoked cert against the CRL confirms revocation:

```
$ make check-leaf-revoked-crl
cat root/ca.crt crl/crl.pem > crl/bundle.pem
openssl verify -extended_crl -verbose -CAfile crl/bundle.pem -crl_check leaf-revoked/leaf.crt
leaf-revoked/leaf.crt: C = US, ST = California, L = San Francisco, OU = My Example Website 2, CN = www2.example.org, emailAddress = user@example.org
error 23 at 0 depth lookup:certificate revoked
make: [check-leaf-revoked-crl] Error 2 (ignored)
```

But the non-revoked cert continues to verify as OK:

```
$ make check-leaf-crl
cat root/ca.crt crl/crl.pem > crl/bundle.pem
openssl verify -extended_crl -verbose -CAfile crl/bundle.pem -crl_check leaf/leaf.crt
leaf/leaf.crt: OK
```

Lastly, if you want to inspect all of the x509v3 extensions for the certificates, you can do so like this:

```
$ make inspect-extensions
ROOT:
        X509v3 extensions:
            X509v3 Basic Constraints: critical
                CA:TRUE, pathlen:0
            X509v3 Subject Key Identifier:
                CD:A8:B5:13:70:47:2A:F3:DA:AD:8F:57:82:5C:5A:A5:52:63:54:14
            X509v3 Authority Key Identifier:
                keyid:CD:A8:B5:13:70:47:2A:F3:DA:AD:8F:57:82:5C:5A:A5:52:63:54:14

            X509v3 Key Usage: critical
                Digital Signature, Certificate Sign, CRL Sign

LEAF:
        X509v3 extensions:
            X509v3 Basic Constraints: critical
                CA:FALSE
            X509v3 Subject Key Identifier:
                D8:85:58:0A:62:4E:66:7B:70:28:63:63:EF:F2:34:FE:D5:67:58:97
            X509v3 Authority Key Identifier:
                keyid:CD:A8:B5:13:70:47:2A:F3:DA:AD:8F:57:82:5C:5A:A5:52:63:54:14

            X509v3 Key Usage: critical
                Digital Signature, Key Encipherment
            Authority Information Access:
                CA Issuers - URI:http://crl.example.com

            X509v3 Subject Alternative Name:
                DNS:www.example.org, DNS:office.example.org

LEAF REVOKED:
        X509v3 extensions:
            X509v3 Basic Constraints: critical
                CA:FALSE
            X509v3 Subject Key Identifier:
                51:D4:5C:52:B3:98:6C:56:2F:DE:67:42:58:89:D1:AB:45:64:C8:4A
            X509v3 Authority Key Identifier:
                keyid:CD:A8:B5:13:70:47:2A:F3:DA:AD:8F:57:82:5C:5A:A5:52:63:54:14

            X509v3 Key Usage: critical
                Digital Signature, Key Encipherment
            Authority Information Access:
                CA Issuers - URI:http://crl.example.com

            X509v3 Subject Alternative Name:
                DNS:www2.example.org, DNS:office2.example.org
```
