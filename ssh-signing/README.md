# openssl-examples - ssh-signing

Here is a basic example of signing ssh public keys using `ssh-keygen`. By running `make inspect`, three things will happen:

* A 'signing' private key will be created, `ca.key` and `ca.key.pub`.
* A private and public key pair will be created, `id` and `id.pub`, the latter of which will later be signed by `ca.key`
* `id.pub` will be signed by `ca.key` resulting in `id-cert.pub`
* `ssh-keygen -L` will be run on the signed public key for inspection

```
$ make inspect
ssh-keygen -f ca.key -C "CA: myca" -b 4096 -V '-1d:+365d' -N ''
Generating public/private rsa key pair.
Your identification has been saved in ca.key.
Your public key has been saved in ca.key.pub.
The key fingerprint is:
SHA256:Co5aK1jljKs4k8eFwFGfrN+tmSjXT4mdY2YE8tl6qjc CA: myca
The key's randomart image is:
+---[RSA 4096]----+
|  ..             |
| .  o .          |
|. .  = .         |
|..  o o +        |
| . B.  oSo       |
|  +o=...* o      |
|.+oo..o+ %       |
|Bo+o ..E@ .      |
|+*. ooo=o.       |
+----[SHA256]-----+
ssh-keygen -f id -C "My Unsigned Key" -b 4096 -V '-1d:+365d' -N ''
Generating public/private rsa key pair.
Your identification has been saved in id.
Your public key has been saved in id.pub.
The key fingerprint is:
SHA256:aW7H37jTv6T9oqfzrWaQwOcNcCXvtbQ2fe2fGhoMT3E My Unsigned Key
The key's randomart image is:
+---[RSA 4096]----+
|            ...  |
|          . .o   |
|         . + E...|
|         .o =...=|
|        S. = +.=+|
|       o .= + o.o|
|        o o+ + ..|
|       . . .=o@.o|
|           .*&=BB|
+----[SHA256]-----+
ssh-keygen -I "Signed by myca" -n "group1,group2" -s ca.key -V '+1h' -z $(date '+%s') id.pub
Signed user key id-cert.pub: id "Signed by myca" serial 1613409081 for group1,group2 valid from 2021-02-15T09:10:00 to 2021-02-15T10:11:21
ssh-keygen -L -f id-cert.pub
id-cert.pub:
        Type: ssh-rsa-cert-v01@openssh.com user certificate
        Public key: RSA-CERT SHA256:aW7H37jTv6T9oqfzrWaQwOcNcCXvtbQ2fe2fGhoMT3E
        Signing CA: RSA SHA256:Co5aK1jljKs4k8eFwFGfrN+tmSjXT4mdY2YE8tl6qjc (using rsa-sha2-512)
        Key ID: "Signed by myca"
        Serial: 1613409081
        Valid: from 2021-02-15T09:10:00 to 2021-02-15T10:11:21
        Principals:
                group1
                group2
        Critical Options: (none)
        Extensions:
                permit-X11-forwarding
                permit-agent-forwarding
                permit-port-forwarding
                permit-pty
                permit-user-rc
```

Notice the `Principals` attribute.  This could be a list of allowed groups found in a [JWT](https://en.wikipedia.org/wiki/JSON_Web_Token) that manages authorization.  The sshd service could limit access to certs signed by `ca.key.pub`, and also to specific groups.
