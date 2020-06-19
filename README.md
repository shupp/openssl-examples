# openssl-examples
This is a place to capture examples of common openssl use cases for future reference.  They are wrapped in easily repeatable `make` commands with related `clean` targets.

* [two-tier](two-tier/) - A simple two tier certificate chain.  One Certificate Authority and one leaf certificate.  It aso includes examples of testing CipherString SECLEVEL values, which is an issue coming up with [debian buster](https://www.debian.org/releases/stable/amd64/release-notes/ch-information.en.html#openssl-defaults).
* [three-tier](three-tier/) - An example three tier chain containing a Root Ceritificate Authority, an Intermediate Certificate Authority, and a leaf certificate.
* [cross-signing](cross-signing/) - An example cross signed three tier chain containing two different Root Ceritificate Authorities, an Intermediate Certificate Authority with a common Certificate Signing Request and private key, but two certificates (each signed by a unique root), and a leaf certificate that validates with either chain.
* [crl](crl/) - An example [Certificate Revocation List](https://en.wikipedia.org/wiki/Certificate_revocation_list) based on a single Certificate Authority, one leaf certificate, and another leaf certificate that has been revoked for "Key Compromise".
* [scrape](scrape/) - Examples of scraping certificates from live services.

From each of these sub-directories, you can use `make all` to see available targets to work with:
```
$ (cd two-tier && make)
Available targets:

all
build
clean
clean-leaf-cert
clean-leaf-csr
clean-leaf-key
clean-root-cert
clean-root-key
clean-serial
help
inspect
inspect-extensions
inspect-leaf
inspect-leaf-csr
inspect-leaf-sha1
inspect-root
leaf/leaf-sha1.crt
leaf/leaf.crt
leaf/leaf.csr
leaf/leaf.key
root/ca.crt
root/ca.key
test-docker
test-http-seclevel1-pass
test-http-seclevel2-fail
test-http-seclevel2-pass
verify
version
```
