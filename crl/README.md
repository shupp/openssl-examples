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
        Last Update: Jun 21 00:18:28 2020 GMT
        Next Update: Jun 21 00:18:28 2021 GMT
        CRL extensions:
            X509v3 Authority Key Identifier:
                keyid:96:9A:63:A8:BB:B4:EE:62:F8:03:B9:2B:DB:D2:21:6E:0C:F4:76:8B
                DirName:/C=US/ST=California/L=San Francisco/OU=Operations/CN=Fake Root CA/emailAddress=fakeroot@example.org
                serial:EB:D1:B8:58:0C:AB:1B:43

            X509v3 CRL Number:
                0
No Revoked Certificates.
    Signature Algorithm: sha256WithRSAEncryption
         af:3e:55:2f:66:57:27:9c:b5:40:1b:c4:28:c9:3f:82:95:b1:
         fd:92:a9:63:29:ab:25:d3:46:bf:9d:bc:3d:43:6b:5e:39:e8:
         d4:75:2b:f8:d8:93:02:de:50:c1:27:88:24:f0:4b:9a:c6:2c:
         21:b2:6e:83:30:2a:9c:e0:fe:29:ef:98:0d:4b:ec:e2:49:30:
         94:de:5c:1c:3c:62:fa:c6:e3:12:70:eb:ea:9b:6d:08:bf:00:
         85:5f:99:e5:a3:c1:94:c9:69:02:af:7b:04:b6:4e:2f:ba:45:
         67:6f:83:47:f8:14:4d:ce:9e:c6:bb:ee:98:ca:b9:42:1a:d7:
         59:01:1d:5e:bd:21:b6:ce:a0:f4:a7:3a:e9:1e:e5:76:03:9d:
         44:f0:09:0c:9a:d6:4d:d4:ad:3a:76:ea:ba:87:4f:f8:25:70:
         7f:55:d6:d9:77:d5:a7:51:02:90:49:a0:26:50:5d:0c:d5:ce:
         0e:70:d0:21:e3:dc:b6:e0:ec:e8:09:cb:e3:cb:29:08:81:05:
         84:ca:04:94:cc:d2:9e:8e:b0:6d:ab:40:37:79:5d:46:53:d9:
         96:e7:4e:4c:73:f4:76:f3:f9:23:5d:3a:b6:39:53:5d:bd:77:
         15:d8:45:7d:b0:a6:42:ef:93:f4:8b:ba:8f:fd:65:13:44:d1:
         2d:f5:16:25
```

Now, let's verify that both certificates are valid and not on the CRL:

```
$ make check-leaf-crl check-leaf-revoked-crl
cat root/ca.crt crl/crl.pem > crl/bundle.pem
openssl verify -extended_crl -verbose -CAfile crl/bundle.pem -crl_check leaf/leaf.crt
leaf/leaf.crt: OK
cat root/ca.crt crl/crl.pem > crl/bundle.pem
openssl verify -extended_crl -verbose -CAfile crl/bundle.pem -crl_check leaf-revoked/leaf.crt
leaf-revoked/leaf.crt: OK
```

Next, we can revoke a certificate using the reason of "Key Compromise":

```
$ make revoke
openssl ca -revoke leaf-revoked/leaf.crt -keyfile root/ca.key -cert root/ca.crt -config crl/crl.conf -crl_reason keyCompromise
Using configuration from crl/crl.conf
Adding Entry with serial number A934117EB7BBD4F2 to DB for /C=US/ST=California/L=San Francisco/OU=My Example Website 2/CN=www2.example.org/emailAddress=user@example.org
Revoking Certificate A934117EB7BBD4F2.
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
        Last Update: Jun 21 00:19:52 2020 GMT
        Next Update: Jun 21 00:19:52 2021 GMT
        CRL extensions:
            X509v3 Authority Key Identifier:
                keyid:96:9A:63:A8:BB:B4:EE:62:F8:03:B9:2B:DB:D2:21:6E:0C:F4:76:8B
                DirName:/C=US/ST=California/L=San Francisco/OU=Operations/CN=Fake Root CA/emailAddress=fakeroot@example.org
                serial:EB:D1:B8:58:0C:AB:1B:43

            X509v3 CRL Number:
                1
Revoked Certificates:
    Serial Number: A934117EB7BBD4F2
        Revocation Date: Jun 21 00:19:52 2020 GMT
        CRL entry extensions:
            X509v3 CRL Reason Code:
                Key Compromise
    Signature Algorithm: sha256WithRSAEncryption
         6d:15:55:72:bf:c9:da:18:54:d5:f4:d0:9b:84:28:5c:b5:36:
         36:79:ce:ef:74:c2:4b:88:ae:d9:ea:32:38:7c:d1:99:9a:3b:
         07:b3:f8:8b:7b:71:c6:bf:af:fe:63:61:26:20:3f:09:23:a1:
         6c:af:c1:07:51:fd:ff:f9:48:17:6d:d0:43:34:1b:8c:92:b1:
         17:92:6c:0c:86:ba:64:f2:a7:f9:74:35:d2:01:ae:3e:ec:c2:
         16:3c:e3:37:07:bd:8c:81:29:25:c5:88:e0:f4:14:5d:54:7f:
         27:1e:23:0c:17:ff:cb:84:c9:d0:4f:33:99:a5:d8:f2:81:27:
         57:d1:9a:28:b4:b7:4d:85:a6:7d:0b:1d:b9:98:69:83:e2:84:
         2b:26:43:bf:d3:5d:00:1d:ef:03:b3:fb:7a:79:3d:06:24:43:
         0b:52:8a:5d:cb:da:bf:2f:4b:14:5e:52:81:e5:b4:42:8e:14:
         43:cd:c0:76:9b:47:3a:37:b4:5f:1b:29:cf:02:b0:f0:0c:29:
         c9:c2:16:5e:9f:7d:a3:77:b0:2c:fb:69:bf:59:33:ee:ea:f3:
         a2:02:0a:c8:9b:cc:ba:b3:aa:3e:0a:3a:b5:c2:c5:e5:4e:59:
         1b:56:60:e8:dc:66:8b:9d:cc:1a:0d:02:fd:60:89:3d:1f:f5:
         fa:11:fb:21
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
                96:9A:63:A8:BB:B4:EE:62:F8:03:B9:2B:DB:D2:21:6E:0C:F4:76:8B
            X509v3 Authority Key Identifier:
                keyid:96:9A:63:A8:BB:B4:EE:62:F8:03:B9:2B:DB:D2:21:6E:0C:F4:76:8B

            X509v3 Key Usage: critical
                Digital Signature, Certificate Sign, CRL Sign

LEAF:
        X509v3 extensions:
            X509v3 Basic Constraints: critical
                CA:FALSE
            X509v3 Subject Key Identifier:
                3C:98:49:5B:1C:B1:88:6F:FD:7B:B3:C6:03:FF:35:4D:AF:29:96:D6
            X509v3 Authority Key Identifier:
                keyid:96:9A:63:A8:BB:B4:EE:62:F8:03:B9:2B:DB:D2:21:6E:0C:F4:76:8B

            X509v3 Key Usage: critical
                Digital Signature, Key Encipherment
            Authority Information Access:
                CA Issuers - URI:http://crl.example.com/issuer.pem

            X509v3 CRL Distribution Points:

                Full Name:
                  URI:http://crl.example.com/crl.pem

            X509v3 Subject Alternative Name:
                DNS:www.example.org, DNS:office.example.org

LEAF REVOKED:
        X509v3 extensions:
            X509v3 Basic Constraints: critical
                CA:FALSE
            X509v3 Subject Key Identifier:
                7F:1C:F2:85:C1:B0:FA:B0:6B:8F:16:3F:4A:34:94:B2:72:71:77:A2
            X509v3 Authority Key Identifier:
                keyid:96:9A:63:A8:BB:B4:EE:62:F8:03:B9:2B:DB:D2:21:6E:0C:F4:76:8B

            X509v3 Key Usage: critical
                Digital Signature, Key Encipherment
            Authority Information Access:
                CA Issuers - URI:http://crl.example.com/issuer.pem

            X509v3 CRL Distribution Points:

                Full Name:
                  URI:http://crl.example.com/crl.pem

            X509v3 Subject Alternative Name:
                DNS:www2.example.org, DNS:office2.example.org
```
