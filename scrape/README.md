# openssl-examples - scrape
Here are some examples of inspecting certificates using `openssl s_client` wrapped in `make`.

## HTTPS example:
Basic text output with defaults:
```
$ make https-www.google.com
echo | openssl s_client -servername www.google.com -showcerts -connect www.google.com:443 \
		| openssl x509 -text
depth=2 OU = GlobalSign Root CA - R2, O = GlobalSign, CN = GlobalSign
verify return:1
depth=1 C = US, O = Google Trust Services, CN = GTS CA 1O1
verify return:1
depth=0 C = US, ST = California, L = Mountain View, O = Google LLC, CN = www.google.com
verify return:1
DONE
Certificate:
    Data:
        Version: 3 (0x2)
        Serial Number:
            1e:f8:50:72:84:a7:7b:ec:02:00:00:00:00:6a:0d:39
    Signature Algorithm: sha256WithRSAEncryption
        Issuer: C=US, O=Google Trust Services, CN=GTS CA 1O1
        Validity
            Not Before: May 20 12:08:31 2020 GMT
            Not After : Aug 12 12:08:31 2020 GMT
        Subject: C=US, ST=California, L=Mountain View, O=Google LLC, CN=www.google.com
        Subject Public Key Info:
            Public Key Algorithm: id-ecPublicKey
                Public-Key: (256 bit)
                pub:
                    04:ef:fd:ae:b5:ee:db:b4:7b:83:29:dd:42:2b:03:
                    4a:8a:71:f9:a3:14:f2:7e:40:ce:b4:e0:28:77:90:
                    73:67:c8:67:02:52:a5:3c:d2:d6:44:83:7b:14:35:
                    3e:90:86:60:55:61:9b:68:4f:99:75:9a:26:67:13:
                    60:4f:66:23:b8
                ASN1 OID: prime256v1
                NIST CURVE: P-256
        X509v3 extensions:
            X509v3 Key Usage: critical
                Digital Signature
            X509v3 Extended Key Usage:
                TLS Web Server Authentication
            X509v3 Basic Constraints: critical
                CA:FALSE
            X509v3 Subject Key Identifier:
                0D:94:9F:90:8A:5C:0E:B5:B5:DB:B7:79:7F:6A:09:42:3A:4D:CC:D4
            X509v3 Authority Key Identifier:
                keyid:98:D1:F8:6E:10:EB:CF:9B:EC:60:9F:18:90:1B:A0:EB:7D:09:FD:2B

            Authority Information Access:
                OCSP - URI:http://ocsp.pki.goog/gts1o1
                CA Issuers - URI:http://pki.goog/gsr2/GTS1O1.crt

            X509v3 Subject Alternative Name:
                DNS:www.google.com
            X509v3 Certificate Policies:
                Policy: 2.23.140.1.2.2
                Policy: 1.3.6.1.4.1.11129.2.5.3

            X509v3 CRL Distribution Points:

                Full Name:
                  URI:http://crl.pki.goog/GTS1O1.crl

            1.3.6.1.4.1.11129.2.4.2:
                ......v......... N.f.+..% gk..p..IS-...^...r23$......G0E.!....*.2....^-....h...'.v..+d....k. z..f..!h.UH..?.....A.z......t....w.^.s..V...6H}.I.2z.............q...[.6.:.ic..f..(q ]...].f&..[.......[3..G..H.E...ym.!..Z
    Signature Algorithm: sha256WithRSAEncryption
         78:b3:02:ed:78:b6:76:31:d4:2e:8b:61:48:6f:fa:c4:3c:36:
         83:db:d9:a0:59:b4:b7:c6:ec:47:f5:11:8d:e1:ad:9c:aa:37:
         bd:e1:4e:fe:e0:94:95:10:55:04:36:61:15:8e:ce:58:50:5d:
         2a:26:39:ad:89:ca:b8:6f:f7:5d:c6:75:f7:45:5f:3a:9f:6c:
         6c:b2:2b:fe:25:7d:fd:34:d9:80:71:d3:6e:1f:62:60:bc:a3:
         39:9a:dc:5c:cc:0a:da:3b:a7:0c:22:db:16:a1:1e:ff:f7:eb:
         63:34:c7:62:c9:8a:ba:a3:46:cb:fe:c1:05:a0:cd:2b:81:4f:
         25:21:aa:ff:ee:c7:27:ba:60:1f:f9:9e:c3:a3:7a:1d:f7:11:
         88:c0:a1:77:a6:ae:1f:6a:80:82:79:3e:5f:02:58:62:3c:fb:
         bf:54:77:0e:ae:2a:76:4e:28:a6:40:09:e0:32:b8:42:92:ee:
         52:21:13:07:82:4e:11:c0:2f:b1:b4:39:7f:f9:db:05:2d:77:
         d2:0b:e6:17:db:66:ee:23:00:2b:e2:40:c1:2f:e5:97:5f:c7:
         03:f0:5d:5f:3a:46:7d:4d:de:d8:90:d0:36:e7:dc:7a:da:b8:
         43:de:d1:04:4a:53:87:7e:ea:6f:c6:c1:18:85:bd:89:87:29:
         ef:13:61:a3
-----BEGIN CERTIFICATE-----
MIIEwDCCA6igAwIBAgIQHvhQcoSne+wCAAAAAGoNOTANBgkqhkiG9w0BAQsFADBC
MQswCQYDVQQGEwJVUzEeMBwGA1UEChMVR29vZ2xlIFRydXN0IFNlcnZpY2VzMRMw
EQYDVQQDEwpHVFMgQ0EgMU8xMB4XDTIwMDUyMDEyMDgzMVoXDTIwMDgxMjEyMDgz
MVowaDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCkNhbGlmb3JuaWExFjAUBgNVBAcT
DU1vdW50YWluIFZpZXcxEzARBgNVBAoTCkdvb2dsZSBMTEMxFzAVBgNVBAMTDnd3
dy5nb29nbGUuY29tMFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAE7/2ute7btHuD
Kd1CKwNKinH5oxTyfkDOtOAod5BzZ8hnAlKlPNLWRIN7FDU+kIZgVWGbaE+ZdZom
ZxNgT2YjuKOCAlUwggJRMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggrBgEF
BQcDATAMBgNVHRMBAf8EAjAAMB0GA1UdDgQWBBQNlJ+QilwOtbXbt3l/aglCOk3M
1DAfBgNVHSMEGDAWgBSY0fhuEOvPm+xgnxiQG6DrfQn9KzBkBggrBgEFBQcBAQRY
MFYwJwYIKwYBBQUHMAGGG2h0dHA6Ly9vY3NwLnBraS5nb29nL2d0czFvMTArBggr
BgEFBQcwAoYfaHR0cDovL3BraS5nb29nL2dzcjIvR1RTMU8xLmNydDAZBgNVHREE
EjAQgg53d3cuZ29vZ2xlLmNvbTAhBgNVHSAEGjAYMAgGBmeBDAECAjAMBgorBgEE
AdZ5AgUDMC8GA1UdHwQoMCYwJKAioCCGHmh0dHA6Ly9jcmwucGtpLmdvb2cvR1RT
MU8xLmNybDCCAQUGCisGAQQB1nkCBAIEgfYEgfMA8QB2ALIeBcyLos2KIE6HZvkr
uYolIGdr2vpw57JJUy3vi5BeAAABcjIzJAEAAAQDAEcwRQIhAKSSjyrRMpMJotRe
LRy8g45o1qyZJwl20r0rZBSA7RlrAiB67LZmFxkhaP9VSLCNP8+vB/3sQYl6g+Lz
/6IMdB2+EQB3AF6nc/nfVsDntTZIfdBJ4DJ6kZoMhKESEoQYdZaBcUVYAAABcjIz
I+4AAAQDAEgwRgIhALk8bOH/ZiblkFv18dqWgBezWzPNkkcAu0iqRdEF9nltAiEA
pFoNhR8Jy3HnDuxbzzYTOrppY4/xZvfuKHEgXRaPAF0wDQYJKoZIhvcNAQELBQAD
ggEBAHizAu14tnYx1C6LYUhv+sQ8NoPb2aBZtLfG7Ef1EY3hrZyqN73hTv7glJUQ
VQQ2YRWOzlhQXSomOa2Jyrhv913GdfdFXzqfbGyyK/4lff002YBx024fYmC8ozma
3FzMCto7pwwi2xahHv/362M0x2LJirqjRsv+wQWgzSuBTyUhqv/uxye6YB/5nsOj
eh33EYjAoXemrh9qgIJ5Pl8CWGI8+79Udw6uKnZOKKZACeAyuEKS7lIhEweCThHA
L7G0OX/52wUtd9IL5hfbZu4jACviQMEv5ZdfxwPwXV86Rn1N3tiQ0Dbn3HrauEPe
0QRKU4d+6m/GwRiFvYmHKe8TYaM=
-----END CERTIFICATE-----
```

Example with overriding `OPENSSL` and `HTTPS_PORT`, as well as re-processing the output to extract certain information:
```
$ OPENSSL=/usr/bin/openssl HTTPS_PORT=443 make https-www.cisco.com 2>/dev/null | openssl x509 -issuer -dates -subject -noout
issuer= /C=US/O=HydrantID (Avalanche Cloud Corporation)/CN=HydrantID SSL ICA G2
notBefore=Nov 13 20:48:19 2019 GMT
notAfter=Nov 13 20:58:00 2021 GMT
subject= /C=US/ST=California/L=San Jose/O=Cisco Systems, Inc./CN=www.cisco.com
```
