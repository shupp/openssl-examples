# openssl-examples - two tier
These examples illustrate a simple two tier certificate chain - a root certificate authority, and a leaf certificate signed by it.  It also includes a `sha1` signed certificate to help test different `CipherString` settings.

To build and test everything, you can just run `make all`.  To look at just the verification and test output, you can run:

```
$ make verify test-docker
openssl verify -CAfile root/ca.crt leaf/leaf.crt
leaf/leaf.crt: OK
openssl verify -CAfile root/ca.crt leaf/leaf-sha1.crt
leaf/leaf-sha1.crt: OK
docker run --rm \
		-v ${PWD}:/two-tier \
		-w /two-tier \
		openssl-examples:latest make test-http-seclevel2-pass test-http-seclevel2-fail test-http-seclevel1-pass
Verify return code: 0 (ok)
Verify return code: 68 (CA signature digest algorithm too weak)
Verify return code: 0 (ok)
```
