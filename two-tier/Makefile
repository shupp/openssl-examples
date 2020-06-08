# Optionall override days
ROOT_DAYS ?= 365
LEAF_DAYS ?= 365

DOCKER_IMAGE = openssl-examples:latest

# Optionally override which openssl version to use
OPENSSL ?= openssl

help:
	@grep '^[^#[:space:]].\+:' Makefile \
		| awk -F: '{ print $$1 }' \
		| sort

all: version build leaf/leaf.crt leaf/leaf-sha1.crt inspect-root inspect-leaf-csr inspect-leaf inspect-leaf-sha1 verify test-docker
version:
	$(OPENSSL) version
verify: leaf/leaf.crt leaf/leaf-sha1.crt root/ca.crt
	$(OPENSSL) verify -CAfile root/ca.crt leaf/leaf.crt
	$(OPENSSL) verify -CAfile root/ca.crt leaf/leaf-sha1.crt
build:
	docker build -t $(DOCKER_IMAGE) .

# ROOT
root/ca.key:
	$(OPENSSL) genrsa -out $@ 2048
root/ca.crt: root/ca.key
	$(OPENSSL) req -config root/ca.conf -x509 -new -key root/ca.key -days $(ROOT_DAYS) -out $@
inspect-root: root/ca.crt
	$(OPENSSL) x509 -text -noout -in root/ca.crt

# LEAF
leaf/leaf.key:
	$(OPENSSL) genrsa -out $@ 2048
leaf/leaf.csr: leaf/leaf.key
	$(OPENSSL) req -config leaf/leaf.csr.conf -new -key leaf/leaf.key -days $(LEAF_DAYS) -out $@
inspect-leaf-csr: leaf/leaf.csr
	$(OPENSSL) req -text -noout -in leaf/leaf.csr
leaf/leaf.crt: leaf/leaf.csr root/ca.crt
	$(OPENSSL) x509 \
		-req -in leaf/leaf.csr -CA root/ca.crt -CAkey root/ca.key -CAcreateserial \
		-extfile leaf/signing.conf -extensions extensions \
		-sha256 -out $@ -days $(LEAF_DAYS)
leaf/leaf-sha1.crt: leaf/leaf.csr root/ca.crt
	$(OPENSSL) x509 \
		-req -in leaf/leaf.csr -CA root/ca.crt -CAkey root/ca.key -CAcreateserial \
		-extfile leaf/signing.conf -extensions extensions \
		-sha1 -out $@ -days $(LEAF_DAYS)
inspect-leaf: leaf/leaf.crt
	$(OPENSSL) x509 -text -noout -in leaf/leaf.crt
inspect-leaf-sha1: leaf/leaf-sha1.crt
	$(OPENSSL) x509 -text -noout -in leaf/leaf-sha1.crt

# TESTS
test-http-seclevel2-pass:
	@OPENSSL_CONF=conf/openssl-seclevel2.conf $(OPENSSL) s_server \
		 -cert leaf/leaf.crt -key leaf/leaf.key -CAfile root/ca.crt -www -accept 2112 2>&1 >/dev/null & \
	PID=$$!; \
	sleep 1; \
	VERIFY_STRING=$$( \
		echo | OPENSSL_CONF=conf/openssl-seclevel2.conf $(OPENSSL) s_client \
		-4 -CAfile root/ca.crt -servername example.org -connect 127.0.0.1:2112 2>/dev/null \
		| grep 'Verify' \
		| sed -e 's/^[[:space:]]*//' \
		| sed -e 's/[[:space:]]*$$//' \
		| sort | uniq \
	); \
	kill -TERM $${PID}; \
	[ "$${VERIFY_STRING}" = "Verify return code: 0 (ok)" ]
	@echo "Verify return code: 0 (ok)"
test-http-seclevel2-fail:
	@OPENSSL_CONF=conf/openssl-seclevel1.conf $(OPENSSL) s_server \
		 -cert leaf/leaf-sha1.crt -key leaf/leaf.key -CAfile root/ca.crt -www -accept 2112 2>&1 >/dev/null & \
	PID=$$!; \
	sleep 1; \
	VERIFY_STRING=$$( \
		echo | OPENSSL_CONF=conf/openssl-seclevel2.conf $(OPENSSL) s_client \
		-4 -CAfile root/ca.crt -servername example.org -connect 127.0.0.1:2112 2>/dev/null \
		| grep 'Verify' \
		| sed -e 's/^[[:space:]]*//' \
		| sed -e 's/[[:space:]]*$$//' \
		| sort | uniq \
	); \
	kill -TERM $${PID}; \
	[ "$${VERIFY_STRING}" = "Verify return code: 68 (CA signature digest algorithm too weak)" ]
	@echo "Verify return code: 68 (CA signature digest algorithm too weak)"
test-http-seclevel1-pass:
	@OPENSSL_CONF=conf/openssl-seclevel1.conf $(OPENSSL) s_server \
		 -cert leaf/leaf-sha1.crt -key leaf/leaf.key -CAfile root/ca.crt -www -accept 2112 2>&1 >/dev/null & \
	PID=$$!; \
	sleep 1; \
	VERIFY_STRING=$$( \
		echo | OPENSSL_CONF=conf/openssl-seclevel1.conf $(OPENSSL) s_client \
		-4 -CAfile root/ca.crt -servername example.org -connect 127.0.0.1:2112 2>/dev/null \
		| grep 'Verify' \
		| sed -e 's/^[[:space:]]*//' \
		| sed -e 's/[[:space:]]*$$//' \
		| sort | uniq \
	); \
	kill -TERM $${PID}; \
	[ "$${VERIFY_STRING}" = "Verify return code: 0 (ok)" ]
	@echo "Verify return code: 0 (ok)"
test-docker:
	docker run --rm \
		-v $${PWD}:/two-tier \
		-w /two-tier \
		$(DOCKER_IMAGE) make test-http-seclevel2-pass test-http-seclevel2-fail test-http-seclevel1-pass



# CLEAN
clean-root-key:
	rm -f root/ca.key
clean-root-cert:
	rm -f root/ca.crt
clean-leaf-csr:
	rm -f leaf/leaf.csr
clean-leaf-key:
	rm -f leaf/leaf.key
clean-leaf-cert:
	rm -f leaf/leaf.crt leaf/leaf-sha1.crt
clean-serial:
	rm -f root/ca.srl
clean: clean-root-cert clean-root-key clean-leaf-key clean-leaf-csr clean-leaf-cert clean-serial
