# openssl-examples - crl + ocsp

Here is a basic example using the openssl ca to generate certificate database for use with a [Certificate Revocation List](https://en.wikipedia.org/wiki/Certificate_revocation_list) and to check over [Online Certificate Status Protocol](https://en.wikipedia.org/wiki/Online_Certificate_Status_Protocol).

To get started, you can run `make prep` to generate the initial root certificate authority, an OCSP signing cert, one leaf certificate, and another leaf certificate to be revoked.

Once that's done, have a look have a look at the empty CRL, and note that the x509v3 CRL Number is `0`:

```
$ make inspect-crl
openssl crl -text -noout -in root/data/crl/crl.pem
Certificate Revocation List (CRL):
        Version 2 (0x1)
    Signature Algorithm: sha256WithRSAEncryption
        Issuer: /C=US/ST=California/L=San Francisco/OU=Operations/CN=Fake Root CA/emailAddress=fakeroot@example.org
        Last Update: Jun 21 00:03:30 2020 GMT
        Next Update: Jun 21 00:03:30 2021 GMT
        CRL extensions:
            X509v3 Authority Key Identifier:
                keyid:01:53:31:4D:4F:C9:17:44:CE:44:41:F9:D7:C7:07:48:D8:79:1D:5B
                DirName:/C=US/ST=California/L=San Francisco/OU=Operations/CN=Fake Root CA/emailAddress=fakeroot@example.org
                serial:CB:98:8D:9B:A0:7C:48:CD

            X509v3 CRL Number:
                0
No Revoked Certificates.
    Signature Algorithm: sha256WithRSAEncryption
         a1:7d:c0:2a:c1:db:01:f2:28:74:be:1a:06:0f:7b:5f:1d:10:
         f0:4d:60:b4:f2:61:72:e8:d2:ab:45:04:74:d8:4c:93:20:07:
         a7:ec:bc:b9:34:a0:82:98:35:2c:cd:8a:2f:e2:a4:d1:87:09:
         49:40:35:72:c3:ac:79:ab:4d:16:47:bb:92:06:45:ac:bd:91:
         3e:c8:97:ed:28:b6:c2:98:d1:b6:a2:1f:c2:ce:8f:1d:5c:a1:
         99:95:22:05:a7:6b:bb:78:e5:7b:c9:49:10:18:9d:91:f0:de:
         c5:f1:a9:a0:87:08:91:7d:ba:51:22:2a:4e:64:58:e1:38:82:
         f4:6d:77:be:d7:e2:91:bb:65:f9:ae:76:f1:e6:9c:53:27:71:
         ad:39:08:60:6b:9d:f8:b4:f1:f4:71:48:0f:c3:27:a2:59:9d:
         fa:e4:96:09:00:50:a2:4a:6b:87:f6:a0:64:42:93:fe:31:58:
         cf:b9:e9:0e:40:6a:36:f3:ba:80:e5:cd:4d:14:37:ea:a2:5e:
         54:54:00:79:eb:b1:9f:91:6b:10:93:ee:ca:c1:95:d8:4a:b7:
         f6:07:d9:5a:73:57:f5:6a:2b:5a:de:82:49:82:f7:39:f1:ac:
         25:b2:b7:a3:97:a2:f0:cd:61:29:21:80:03:ea:be:d8:36:60:
         b9:8e:5d:7d
```

Now, let's verify that both certificates are valid and not on the CRL:

```
$ make check-leaf-crl check-leaf-revoked-crl
cat root/ca.crt root/data/crl/crl.pem > root/data/crl/bundle.pem
openssl verify -extended_crl -verbose -CAfile root/data/crl/bundle.pem -crl_check leaf/leaf.crt
leaf/leaf.crt: OK
openssl verify -extended_crl -verbose -CAfile root/data/crl/bundle.pem -crl_check leaf-revoked/leaf.crt
leaf-revoked/leaf.crt: OK
```

We can also verify these via OCSP. However, the standard version of OpenSSL that ships with macOS is LibreSSL 2.6.5, which won't work for this.  You'll want openssl 1.1 or later, which can be installed via brew.  Here's an example of running the ocsp checks using openssl@1.1:

```
$ OPENSSL=/usr/local/Cellar/openssl@1.1/1.1.1g/bin/openssl make test-ocsp-ok test-ocsp-revoked
/usr/local/Cellar/openssl@1.1/1.1.1g/bin/openssl ocsp \
			-index root/data/index.txt -port 8080 \
			-rsigner ocsp-signer/ocsp.crt -rkey ocsp-signer/ocsp.key -CA root/ca.crt -out root/data/log.txt & \
		PID=$!; \
		sleep 1; \
		/usr/local/Cellar/openssl@1.1/1.1.1g/bin/openssl ocsp \
			-CAfile root/ca.crt -issuer root/ca.crt \
			-cert leaf/leaf.crt -url http://127.0.0.1:8080; \
		kill -TERM ${PID}
ocsp: waiting for OCSP client connections...
Response verify OK
leaf/leaf.crt: good
	This Update: Jun 21 00:04:26 2020 GMT
/usr/local/Cellar/openssl@1.1/1.1.1g/bin/openssl ocsp \
			-index root/data/index.txt -port 8080 \
			-rsigner ocsp-signer/ocsp.crt -rkey ocsp-signer/ocsp.key -CA root/ca.crt -out root/data/log.txt & \
		PID=$!; \
		sleep 1; \
		/usr/local/Cellar/openssl@1.1/1.1.1g/bin/openssl ocsp \
			-CAfile root/ca.crt -issuer root/ca.crt \
			-cert leaf-revoked/leaf.crt -url http://127.0.0.1:8080; \
		kill -TERM ${PID}
ocsp: waiting for OCSP client connections...
Response verify OK
leaf-revoked/leaf.crt: good
	This Update: Jun 21 00:04:27 2020 GMT
```

Next, we can revoke a certificate using the reason of "Key Compromise":

```
$ make revoke
OPENSSL_CONF=root/ca.conf openssl \
		ca -revoke leaf-revoked/leaf.crt -crl_reason keyCompromise
Using configuration from root/ca.conf
Revoking Certificate 01.
Data Base Updated
OPENSSL_CONF=root/ca.conf openssl ca -gencrl -out root/data/crl/crl.pem
Using configuration from root/ca.conf
```

If we inspect the CRL now, you'll see the revoked cert and that the x509v3 CRL number has incremented to `1`:

```
$ make inspect-crl
openssl crl -text -noout -in root/data/crl/crl.pem
Certificate Revocation List (CRL):
        Version 2 (0x1)
    Signature Algorithm: sha256WithRSAEncryption
        Issuer: /C=US/ST=California/L=San Francisco/OU=Operations/CN=Fake Root CA/emailAddress=fakeroot@example.org
        Last Update: Jun 21 00:04:46 2020 GMT
        Next Update: Jun 21 00:04:46 2021 GMT
        CRL extensions:
            X509v3 Authority Key Identifier:
                keyid:01:53:31:4D:4F:C9:17:44:CE:44:41:F9:D7:C7:07:48:D8:79:1D:5B
                DirName:/C=US/ST=California/L=San Francisco/OU=Operations/CN=Fake Root CA/emailAddress=fakeroot@example.org
                serial:CB:98:8D:9B:A0:7C:48:CD

            X509v3 CRL Number:
                1
Revoked Certificates:
    Serial Number: 01
        Revocation Date: Jun 21 00:04:46 2020 GMT
        CRL entry extensions:
            X509v3 CRL Reason Code:
                Key Compromise
    Signature Algorithm: sha256WithRSAEncryption
         66:b8:f6:31:e7:d3:c5:31:ca:eb:dd:a2:36:5e:65:4f:aa:2a:
         e9:55:81:90:c3:13:57:4e:e3:cd:03:02:54:21:79:26:9d:7e:
         a6:2e:b2:f5:03:1c:52:2b:29:95:8c:93:21:64:84:6d:d5:a2:
         07:19:1a:d7:a1:f4:51:e9:19:a2:27:4b:05:d2:2f:51:26:39:
         e9:43:95:55:d9:85:7d:0f:83:99:3e:f5:7b:4d:1f:54:c2:04:
         30:41:f6:e6:4a:13:d8:e8:74:84:99:36:3a:0d:fb:80:ff:0e:
         3b:47:20:d5:96:ac:f3:99:8b:f2:38:6b:ef:94:b3:72:eb:84:
         c9:3a:74:10:2d:93:28:2d:32:62:8c:e7:d9:2e:8f:86:b3:17:
         c3:72:c8:0d:ba:4a:18:59:b1:20:bc:5d:0d:af:64:8f:53:f5:
         22:1f:8c:45:ab:a8:48:24:6c:35:bf:e0:e4:9f:7e:5b:f4:2a:
         71:80:8d:30:40:63:53:5b:bb:2d:61:88:32:ec:89:15:47:c4:
         9e:f9:28:dc:5c:1a:a0:67:79:f8:d3:49:18:c1:49:0d:3f:02:
         61:9a:e4:db:5a:f5:21:0f:79:84:5c:b6:3c:38:76:ba:69:97:
         eb:ef:d6:0b:d9:d7:77:79:57:c6:48:00:89:4a:62:59:75:f1:
         81:42:f9:96
```

Also, the we can see that checking the revoked cert against the CRL confirms revocation:

```
$ make check-leaf-revoked-crl
cat root/ca.crt root/data/crl/crl.pem > root/data/crl/bundle.pem
openssl verify -extended_crl -verbose -CAfile root/data/crl/bundle.pem -crl_check leaf-revoked/leaf.crt
leaf-revoked/leaf.crt: CN = www2.example.org, ST = California, C = US, OU = My Example Website 2, emailAddress = user@example.org
error 23 at 0 depth lookup:certificate revoked
make: [check-leaf-revoked-crl] Error 2 (ignored)
```

But the non-revoked cert continues to verify as OK:

```
$ make check-leaf-crl
cat root/ca.crt root/data/crl/crl.pem > root/data/crl/bundle.pem
openssl verify -extended_crl -verbose -CAfile root/data/crl/bundle.pem -crl_check leaf/leaf.crt
leaf/leaf.crt: OK
```

And we can check the same things over OCSP:

```
$ OPENSSL=/usr/local/Cellar/openssl@1.1/1.1.1g/bin/openssl make test-ocsp-ok test-ocsp-revoked
/usr/local/Cellar/openssl@1.1/1.1.1g/bin/openssl ocsp \
			-index root/data/index.txt -port 8080 \
			-rsigner ocsp-signer/ocsp.crt -rkey ocsp-signer/ocsp.key -CA root/ca.crt -out root/data/log.txt & \
		PID=$!; \
		sleep 1; \
		/usr/local/Cellar/openssl@1.1/1.1.1g/bin/openssl ocsp \
			-CAfile root/ca.crt -issuer root/ca.crt \
			-cert leaf/leaf.crt -url http://127.0.0.1:8080; \
		kill -TERM ${PID}
ocsp: waiting for OCSP client connections...
Response verify OK
leaf/leaf.crt: good
	This Update: Jun 21 00:05:55 2020 GMT
/usr/local/Cellar/openssl@1.1/1.1.1g/bin/openssl ocsp \
			-index root/data/index.txt -port 8080 \
			-rsigner ocsp-signer/ocsp.crt -rkey ocsp-signer/ocsp.key -CA root/ca.crt -out root/data/log.txt & \
		PID=$!; \
		sleep 1; \
		/usr/local/Cellar/openssl@1.1/1.1.1g/bin/openssl ocsp \
			-CAfile root/ca.crt -issuer root/ca.crt \
			-cert leaf-revoked/leaf.crt -url http://127.0.0.1:8080; \
		kill -TERM ${PID}
ocsp: waiting for OCSP client connections...
Response verify OK
leaf-revoked/leaf.crt: revoked
	This Update: Jun 21 00:05:56 2020 GMT
	Reason: keyCompromise
	Revocation Time: Jun 21 00:04:46 2020 GMT
```

Lastly, if you want to inspect all of the x509v3 extensions for the certificates, you can do so like this:

```
$ make inspect-extensions
ROOT:
        X509v3 extensions:
            X509v3 Basic Constraints: critical
                CA:TRUE, pathlen:0
            X509v3 Subject Key Identifier:
                01:53:31:4D:4F:C9:17:44:CE:44:41:F9:D7:C7:07:48:D8:79:1D:5B
            X509v3 Authority Key Identifier:
                keyid:01:53:31:4D:4F:C9:17:44:CE:44:41:F9:D7:C7:07:48:D8:79:1D:5B

            X509v3 Key Usage: critical
                Digital Signature, Certificate Sign, CRL Sign

OCSP SIGNER:
        X509v3 extensions:
            X509v3 Basic Constraints: critical
                CA:FALSE
            X509v3 Subject Key Identifier:
                99:17:A8:87:F4:04:24:38:48:06:6B:6F:8C:04:1D:1F:07:4D:0D:93
            X509v3 Authority Key Identifier:
                keyid:01:53:31:4D:4F:C9:17:44:CE:44:41:F9:D7:C7:07:48:D8:79:1D:5B

            X509v3 Key Usage: critical
                Digital Signature, Non Repudiation, Key Encipherment
            X509v3 Extended Key Usage:
                OCSP Signing

LEAF:
        X509v3 extensions:
            X509v3 Basic Constraints: critical
                CA:FALSE
            X509v3 Subject Key Identifier:
                23:58:8B:C5:DD:16:21:00:FE:61:E6:36:A0:10:D2:FA:D8:40:05:0C
            X509v3 Authority Key Identifier:
                keyid:01:53:31:4D:4F:C9:17:44:CE:44:41:F9:D7:C7:07:48:D8:79:1D:5B

            X509v3 Key Usage: critical
                Digital Signature, Key Encipherment
            Authority Information Access:
                OCSP - URI:http://127.0.0.1:8080
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
                FC:65:B1:81:E1:54:18:3E:C3:B5:BC:48:EB:B6:30:4C:72:8D:40:BC
            X509v3 Authority Key Identifier:
                keyid:01:53:31:4D:4F:C9:17:44:CE:44:41:F9:D7:C7:07:48:D8:79:1D:5B

            X509v3 Key Usage: critical
                Digital Signature, Key Encipherment
            Authority Information Access:
                OCSP - URI:http://127.0.0.1:8080
                CA Issuers - URI:http://crl.example.com/issuer.pem

            X509v3 CRL Distribution Points:

                Full Name:
                  URI:http://crl.example.com/crl.pem

            X509v3 Subject Alternative Name:
                DNS:www2.example.org, DNS:office2.example.org
```
