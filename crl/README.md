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
        Last Update: Jun 18 18:46:50 2020 GMT
        Next Update: Jun 18 18:46:50 2021 GMT
        CRL extensions:
            X509v3 CRL Number:
                0
No Revoked Certificates.
    Signature Algorithm: sha256WithRSAEncryption
         95:b2:b0:ab:3f:4f:fe:d5:a6:00:63:a3:5d:7b:d4:b1:b5:d4:
         d5:52:6e:52:24:8e:6a:8a:cb:02:d7:3a:29:bf:5d:41:03:0b:
         15:d0:87:00:6e:82:61:57:11:c3:16:5d:94:00:1f:94:4c:af:
         38:75:15:ac:c8:e4:96:72:db:e4:b2:27:7f:1b:62:69:b8:cf:
         d1:69:09:56:aa:5f:d4:7c:cc:dd:4c:aa:a5:da:7e:19:87:bf:
         ac:af:a6:88:a5:4d:67:75:1d:a0:e0:9e:f6:95:d4:6b:a9:2e:
         ab:10:c4:72:0d:d4:ef:90:f7:c7:96:16:50:12:b9:db:2d:20:
         d9:9d:7b:f5:70:39:0e:22:22:ae:4f:dc:1e:2a:1d:b2:41:33:
         77:9b:d5:9c:47:60:0e:1f:7b:67:c7:49:6b:18:e3:81:a6:2a:
         2a:4d:6c:22:03:1e:cb:2c:c2:ef:db:17:25:36:71:fc:e3:06:
         11:07:15:ef:d0:4f:18:68:04:66:7a:d3:80:fe:a6:2f:17:70:
         01:74:55:d9:86:32:ee:33:e6:dc:41:bc:b0:10:79:37:34:82:
         c1:24:ed:b9:76:db:1f:46:0e:9a:d9:c3:d3:cf:7b:82:e4:e6:
         f6:ea:cd:09:a4:47:8d:4b:a9:cb:8b:81:21:e6:b4:33:6c:3a:
         5d:e9:7d:80
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

Next, we can revoke a certificate:

```
$ make revoke
openssl ca -revoke leaf-revoked/leaf.crt -keyfile root/ca.key -cert root/ca.crt -config crl/crl.conf
Using configuration from crl/crl.conf
Adding Entry with serial number C19117849FD31C07 to DB for /C=US/ST=California/L=San Francisco/OU=My Example Website 2/CN=www2.example.org/emailAddress=user@example.org
Revoking Certificate C19117849FD31C07.
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
        Last Update: Jun 18 18:48:31 2020 GMT
        Next Update: Jun 18 18:48:31 2021 GMT
        CRL extensions:
            X509v3 CRL Number:
                1
Revoked Certificates:
    Serial Number: C19117849FD31C07
        Revocation Date: Jun 18 18:48:31 2020 GMT
    Signature Algorithm: sha256WithRSAEncryption
         3a:11:62:d7:3a:4b:31:1a:f0:ad:b2:8b:cc:e0:cb:46:8c:07:
         99:75:ca:8a:aa:00:d1:72:42:b2:c7:6f:dd:70:46:8c:31:1c:
         7b:21:0a:c7:04:1b:15:88:15:da:5b:0d:c3:1a:b3:22:40:86:
         2c:35:67:f9:11:04:22:2e:c5:0f:e7:9e:bf:53:b6:77:78:eb:
         70:48:7c:38:e7:73:a2:c5:59:27:09:40:78:59:24:5e:a2:a8:
         f8:9c:06:b3:48:c7:5d:e4:a6:5e:9e:95:43:a0:2d:d6:42:fd:
         d7:31:db:50:63:77:80:ca:8d:db:14:c4:32:9c:59:9b:cf:3b:
         21:1b:f3:e1:1f:4c:40:3f:26:21:d3:5c:cb:5b:76:1a:62:bd:
         d0:91:8e:f4:26:b1:8f:13:58:29:39:07:48:7a:68:8d:39:42:
         93:27:43:f0:69:13:6a:ae:b5:f6:90:ee:05:95:e8:67:b4:35:
         fd:8b:27:86:c3:30:17:56:94:c8:8e:95:14:25:cf:7b:75:3a:
         e8:b7:4f:28:20:7b:32:18:b0:d6:6b:56:f7:68:9a:96:c9:58:
         2d:73:86:d5:6d:ef:51:5e:18:6d:88:5b:8f:70:47:04:b1:b0:
         0d:4d:26:98:67:8a:fa:c7:53:c1:e6:01:28:1a:57:55:b2:a6:
         3d:a5:3e:13
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
