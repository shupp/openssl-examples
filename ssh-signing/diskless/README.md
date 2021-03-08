# openssl-examples - ssh-signing - diskless

Here is a basic example of signing ssh public keys using `ssh-keygen`, and using named pipes to avoid writing to disk. By running `make create-and-sign`, three things will happen:

* A 'signing' private and public CA key pair will be created
* A private and public USER key pair will be created, the latter of which will later be signed
* The public USER key will get signed by the private CA key
* All keys are returned as JSON, without having been written to disk

```
$ make create-and-sign | jq -r .
{
  "ca_private_key": "-----BEGIN OPENSSH PRIVATE KEY-----\nb3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAABFwAAAAdzc2gtcn\nNhAAAAAwEAAQAAAQEArraOGCtKv55kTEb5W8UePxKJInTkuBepIUmbgzkp1mPgpwZNZdZ8\nQORMg7/rVYhkyYubb1VlcEqm+scKfkcviVZChReRKnDn7Axyf2WK7DjUVj52KZk0U6lKh5\nUMx099lVLtUA5qxzYTFAJSZuOAC9IXq7Xoc5+YE2cWP0pZR4so9jxHmoLzazaIOHz4+oYi\noEEyRTBZwcjs6BPC1KmVt7xIM+Y3Pker3gdWhlslN9pgvbW+ObKosY4IYpG9V8JI5R2zN1\nDvD24odS+6VmXgH3+NB6uO4Bw4hlwp+thSn3qaRUqsaiOfBUqwPDMWVtDUL4wZKAVSnGZa\nKeVhKw1VEQAAA8A3G5QANxuUAAAAAAdzc2gtcnNhAAABAQCuto4YK0q/nmRMRvlbxR4/Eo\nkidOS4F6khSZuDOSnWY+CnBk1l1nxA5EyDv+tViGTJi5tvVWVwSqb6xwp+Ry+JVkKFF5Eq\ncOfsDHJ/ZYrsONRWPnYpmTRTqUqHlQzHT32VUu1QDmrHNhMUAlJm44AL0hertehzn5gTZx\nY/SllHiyj2PEeagvNrNog4fPj6hiKgQTJFMFnByOzoE8LUqZW3vEgz5jc+R6veB1aGWyU3\n2mC9tb45sqixjghikb1XwkjlHbM3UO8Pbih1L7pWZeAff40Hq47gHDiGXCn62FKfeppFSq\nxqI58FSrA8MxZW0NQvjBkoBVKcZlop5WErDVURAAAAAwEAAQAAAQBJfiFnqU5YLJikPXbH\nU7PVdEabZ/COP+W1SvFP0cv3kyv9FnmYTREXevF0ulaUNDuxTDimLJXvFngHJZMUa31jmB\nWDRtaZs8TbVqETVfOKSp2Had7qwLdyOdRQFDK75IQ/PBL3ihkAk46S7CcdgLVsQ4QRhwOx\nH4EpKEQDe5LytLUJJY/OKJKlhafgmq4QK8MemGqEN5w9oXsjJb6tPmU087aItsuHlCyHoP\nOoo/x2KH0Yj0L6OQQIY5fLdSExnqvssO1CESuOSOkk0uhaibDVsp3hY2lT5Ua8chqT1H+d\nH0eQ5DT+yDKqhEph31gH7rOXaJj+WmDteEy6UvtBhb/BAAAAgQDZk+G15ZgpxuQqWU5En+\npMljof7PkhSRzwaoB8y2LryX7WD1le0P4mBlsqGESvqoS8HolOem6VpySfd8/Y+926goeo\nuCyb5L98UMw5W6Z+i8wg37JxHGenxq8Y1kAT9jqQ4rz0B6kezh/sazwSiRPkqtTJQtfOEl\nNGChOGcmnq/wAAAIEA25qp1R/ZR833SILq7Gwc6gDwTLSnLwa7/7WUEeQKDQZkjmAAZMKS\nPmF/4DBKqHkdJJZgyg2vbYKOYzACK+U6LPHPVUUiO93N0ieVv/AgdHcYn0BlOID8LiJbfj\najt29bldA5b8MQCxdmOaIuH4lsmXTNK4+U//32xdmBgDW4E8sAAACBAMurQpPf6ktadVr9\nT1mRSpVjLu+y/HWQuhZPdpxojYiDWWb0UAQfl9KO+ek/HMWaSqaso+PjizJBgAPZvVx9rS\nC/e0syiAR4mutZFCKwGHHBVMTh27UYtk2ILG+vj80YW+QQ0P8dEtJOjVnebG5XD5TcEAxJ\nXSmv4ePHZ2SOgfcTAAAACENBOiBteWNhAQI=\n-----END OPENSSH PRIVATE KEY-----",
  "ca_public_key": "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCuto4YK0q/nmRMRvlbxR4/EokidOS4F6khSZuDOSnWY+CnBk1l1nxA5EyDv+tViGTJi5tvVWVwSqb6xwp+Ry+JVkKFF5EqcOfsDHJ/ZYrsONRWPnYpmTRTqUqHlQzHT32VUu1QDmrHNhMUAlJm44AL0hertehzn5gTZxY/SllHiyj2PEeagvNrNog4fPj6hiKgQTJFMFnByOzoE8LUqZW3vEgz5jc+R6veB1aGWyU32mC9tb45sqixjghikb1XwkjlHbM3UO8Pbih1L7pWZeAff40Hq47gHDiGXCn62FKfeppFSqxqI58FSrA8MxZW0NQvjBkoBVKcZlop5WErDVUR CA: myca",
  "user_private_key": "-----BEGIN OPENSSH PRIVATE KEY-----\nb3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAABFwAAAAdzc2gtcn\nNhAAAAAwEAAQAAAQEAliRIWoIQg4U4Bn9NMSVsklUKIjkVgHcVNU4FVM4ekKuRlYYt5fsZ\n7Epn4U56eulWwh4/Frmc0eL3y7gA67E0jvMj9azK1LieY49PchhuzqpaOzZWR7E0v/rBLS\nwDchC3CQdh52hmO8JGGm0AFJAHDHao6xCAlrYe2F5cDcmtxHWDf2vS5hTXuH0+7B0V2xgH\n831oDJSBGIJcRl06jXbJsQZTvmeOLElJu8Dgnu0FmyGangeKoRPbK0CYOhsQuBWyRqxEzl\n/22OFt/f5GtrQWpd/6tcAzsx9WSpCgFLzr5L6t0HS/I7OVVJJ/mUnYrfvfsa12xjO87uKA\nfrJFtzU+xwAAA8grYdrMK2HazAAAAAdzc2gtcnNhAAABAQCWJEhaghCDhTgGf00xJWySVQ\noiORWAdxU1TgVUzh6Qq5GVhi3l+xnsSmfhTnp66VbCHj8WuZzR4vfLuADrsTSO8yP1rMrU\nuJ5jj09yGG7Oqlo7NlZHsTS/+sEtLANyELcJB2HnaGY7wkYabQAUkAcMdqjrEICWth7YXl\nwNya3EdYN/a9LmFNe4fT7sHRXbGAfzfWgMlIEYglxGXTqNdsmxBlO+Z44sSUm7wOCe7QWb\nIZqeB4qhE9srQJg6GxC4FbJGrETOX/bY4W39/ka2tBal3/q1wDOzH1ZKkKAUvOvkvq3QdL\n8js5VUkn+ZSdit+9+xrXbGM7zu4oB+skW3NT7HAAAAAwEAAQAAAQA3BF6bA9QnTZbFErrn\nim4phQ3sknxlkb1sxgVAGTOsEaKMZxnEj2nlYzKDpi1Ngtmu0kSOAEANzRy+QtPbihjXVR\nNVQBcnMeugUfBrv7ZC9ruPvQ6KwM2yl6FX+yvcDXH01gazNFdaCIuFvXFtF4XttEGbuXVV\nRLEy2gjjaIbLWTC/TpLTTlN2k93NwE4FK0cunUUkwGqTNPjywYYggpteZJPzLXttjEkf9c\nJwXFvZZrZh2sKeCA8PO2kBI2rNyIBXOoOYxy0aOvuwmTB8ZA1VbJnjpKV3mZOSSylANVGj\nNGS4SFDK6Ayt3GoWZ3iti5H+/8/75w+1Rs49shhFISXpAAAAgH9Fl4OLc1jiQ2fyqO54vj\n+etubWj6sjw2WHZnj34WuQShenERWu0fiK6BT4PgODE+M+cqJ+dNx0yjCCgKHw7AznBWFN\nLU0U5BogriXU2jB3d801S2trStvaB2wdssnnLjY1RrdJzCwxEqSBBa5xX8qP6NDkjhfEdz\n8U7r+4geT9AAAAgQDGwO2NiD9MqLXUqvpp0FhrDrOAjk3qjfdorKNi9aoy0uKfrFboMZK9\nstPcnTUibjijA3QIlJyReJrHvzTlaMK+hq2bzy+6PW7RotZNaYsydnI0MEpYDw1xYRLVuF\njKFhFwozqWrW3ZWtCSutP8Nqylgv0zD8kDx2aBqnm3H6XYDQAAAIEAwWL2iSTlv7ZhcrOE\nINPz8GfDajd3TQB39CsaH+OFID5C5BM+Ykx1AIvMyUTQhTs7KHwLX+2hSY5gm2tc7BgJui\n2c9ouVRga9XscXCMCR4nl+xlvb/YQJP0HKgTVAj69g7MAZr9d41QRUzKKTwvpRez62al5o\nTAN1bxr/8SxhSSMAAAAMVVNFUjogbXl1c2VyAQIDBAUGBw==\n-----END OPENSSH PRIVATE KEY-----",
  "user_public_key": "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCWJEhaghCDhTgGf00xJWySVQoiORWAdxU1TgVUzh6Qq5GVhi3l+xnsSmfhTnp66VbCHj8WuZzR4vfLuADrsTSO8yP1rMrUuJ5jj09yGG7Oqlo7NlZHsTS/+sEtLANyELcJB2HnaGY7wkYabQAUkAcMdqjrEICWth7YXlwNya3EdYN/a9LmFNe4fT7sHRXbGAfzfWgMlIEYglxGXTqNdsmxBlO+Z44sSUm7wOCe7QWbIZqeB4qhE9srQJg6GxC4FbJGrETOX/bY4W39/ka2tBal3/q1wDOzH1ZKkKAUvOvkvq3QdL8js5VUkn+ZSdit+9+xrXbGM7zu4oB+skW3NT7H USER: myuser",
  "user_public_key_signed": "ssh-rsa-cert-v01@openssh.com AAAAHHNzaC1yc2EtY2VydC12MDFAb3BlbnNzaC5jb20AAAAgF4M/txPfoIZnJbXIzVzGF7rNaqD3XOpus7D93KoEfPwAAAADAQABAAABAQCWJEhaghCDhTgGf00xJWySVQoiORWAdxU1TgVUzh6Qq5GVhi3l+xnsSmfhTnp66VbCHj8WuZzR4vfLuADrsTSO8yP1rMrUuJ5jj09yGG7Oqlo7NlZHsTS/+sEtLANyELcJB2HnaGY7wkYabQAUkAcMdqjrEICWth7YXlwNya3EdYN/a9LmFNe4fT7sHRXbGAfzfWgMlIEYglxGXTqNdsmxBlO+Z44sSUm7wOCe7QWbIZqeB4qhE9srQJg6GxC4FbJGrETOX/bY4W39/ka2tBal3/q1wDOzH1ZKkKAUvOvkvq3QdL8js5VUkn+ZSdit+9+xrXbGM7zu4oB+skW3NT7HAAAAAGBD4jcAAAABAAAADlNpZ25lZCBieSBteWNhAAAAFAAAAAZncm91cDEAAAAGZ3JvdXAyAAAAAGBD4dQAAAAAYEPwRwAAAAAAAACCAAAAFXBlcm1pdC1YMTEtZm9yd2FyZGluZwAAAAAAAAAXcGVybWl0LWFnZW50LWZvcndhcmRpbmcAAAAAAAAAFnBlcm1pdC1wb3J0LWZvcndhcmRpbmcAAAAAAAAACnBlcm1pdC1wdHkAAAAAAAAADnBlcm1pdC11c2VyLXJjAAAAAAAAAAAAAAEXAAAAB3NzaC1yc2EAAAADAQABAAABAQCuto4YK0q/nmRMRvlbxR4/EokidOS4F6khSZuDOSnWY+CnBk1l1nxA5EyDv+tViGTJi5tvVWVwSqb6xwp+Ry+JVkKFF5EqcOfsDHJ/ZYrsONRWPnYpmTRTqUqHlQzHT32VUu1QDmrHNhMUAlJm44AL0hertehzn5gTZxY/SllHiyj2PEeagvNrNog4fPj6hiKgQTJFMFnByOzoE8LUqZW3vEgz5jc+R6veB1aGWyU32mC9tb45sqixjghikb1XwkjlHbM3UO8Pbih1L7pWZeAff40Hq47gHDiGXCn62FKfeppFSqxqI58FSrA8MxZW0NQvjBkoBVKcZlop5WErDVURAAABFAAAAAxyc2Etc2hhMi01MTIAAAEAIXYsp3jCO01twXQlf18fU1C9vZ6G+Byv/ZrjXi/A1VNi98vDqfBKtb3F9SJ7iwynVj4KOx2JoavSdPzK7aZ9Kf/SN9VdIexR4wCBY45P/Sm+vrkYb6x0TeEsdg32iBmVtAqH1dCsbwf8AFUJ7XWxESR02l6/2n0LrEbOLA5+3kCbQggLmVfATjQiW1Jl5lxr+CQ4U8nY0Yti4on6AnZlNY5koBZHE1MTreMnSHi0MlGGvQVWJbLLkMncEkmMDKN6kydzTEwlXmPIxuRx2j4oGQuwpEKs6mNPVFnqI6WSiXw/1PulMyIYekPt/40ZZLGUUwlAJPWAPceVNzn+FYUIAw== USER: myuser"
}
```

There is also a target if you just want to inspect the signed cert:
```
$ make sign-and-inspect
./create-and-sign.sh | jq -r .user_public_key_signed > user-cert.pub
ssh-keygen -Lf user-cert.pub
user-cert.pub:
        Type: ssh-rsa-cert-v01@openssh.com user certificate
        Public key: RSA-CERT SHA256:R1vpNX9+Ndz9i+CH+nVxLpGxCb7I57+U1M8yF9XaUC8
        Signing CA: RSA SHA256:G80drrYUlr3tdZOxJT46vU5FbUtvEenzuBsotOvQUv4 (using rsa-sha2-512)
        Key ID: "Signed by myca"
        Serial: 1615061816
        Valid: from 2021-03-06T12:15:00 to 2021-03-06T13:16:56
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
rm -f user-cert.pub
```
