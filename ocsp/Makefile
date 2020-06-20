.PHONY: root/data/crl/bundle.pem revoke

# Optionall override days
ROOT_DAYS ?= 365
LEAF_DAYS ?= 365
OCSP_DAYS ?= 365

# Optionally override which openssl version to use
OPENSSL ?= openssl

OPENSSL_CONF = root/ca.conf
DATA_DEPS = root/data/serial root/data/certs root/data/index.txt root/data/crl/crlnumber
GENERATE_DEPS = root/ca.crt root/ca.key $(DATA_DEPS)
GENERATE = OPENSSL_CONF=$(OPENSSL_CONF) $(OPENSSL) ca -gencrl -out root/data/crl/crl.pem
CERT_OPTS = no_subject,no_header,no_version,no_serial,no_signame,no_validity,no_issuer,no_pubkey,no_sigdump,no_aux

help:
	@echo "Available targets:\n"
	@grep '^[^#[:space:]]\+:' Makefile \
		| awk -F: '{ print $$1 }' \
		| sort

prep: leaf/leaf.crt leaf-revoked/leaf.crt root/data/crl/bundle.pem ocsp-signer/ocsp.crt

version:
	$(OPENSSL) version

inspect-extensions: | $(DATA_DEPS) root/ca.crt ocsp-signer/ocsp.crt leaf/leaf.crt leaf-revoked/leaf.crt
	@echo "ROOT":
	@$(OPENSSL) x509 -in root/ca.crt -text -certopt $(CERT_OPTS) -noout
	@echo
	@echo "OCSP SIGNER":
	@$(OPENSSL) x509 -in ocsp-signer/ocsp.crt -text -certopt $(CERT_OPTS) -noout
	@echo
	@echo "LEAF":
	@$(OPENSSL) x509 -in leaf/leaf.crt -text -certopt $(CERT_OPTS) -noout
	@echo
	@echo "LEAF REVOKED":
	@$(OPENSSL) x509 -in leaf-revoked/leaf.crt -text -certopt $(CERT_OPTS) -noout


# ROOT
root/ca.key:
	$(OPENSSL) genrsa -out $@ 2048
root/ca.crt: root/ca.key
	$(OPENSSL) req -config root/ca.crt.conf -x509 -new -key root/ca.key -days $(ROOT_DAYS) -out $@
inspect-root: root/ca.crt
	$(OPENSSL) x509 -text -noout -in root/ca.crt

# CA DATA DIRS
root/data/certs:
	mkdir -p $@
root/data/serial:
	mkdir -p root/data
	echo 00 > $@
root/data/index.txt:
	mkdir -p root/data
	touch $@
root/data/crl/crlnumber:
	mkdir -p root/data/crl
	echo 00 > $@

# LEAF
leaf/leaf.key:
	$(OPENSSL) genrsa -out $@ 2048
leaf/leaf.csr: leaf/leaf.key
	$(OPENSSL) req -config leaf/csr.conf -new -key leaf/leaf.key -days $(LEAF_DAYS) -out $@
inspect-leaf-csr: leaf/leaf.csr
	$(OPENSSL) req -text -noout -in leaf/leaf.csr
leaf/leaf.crt: | leaf/leaf.csr root/ca.crt $(DATA_DEPS)
	OPENSSL_CONF=$(OPENSSL_CONF) $(OPENSSL) ca -batch \
		-in leaf/leaf.csr  \
		-extfile leaf/signing.conf -extensions extensions \
		-out $@ -days $(LEAF_DAYS)
inspect-leaf: leaf/leaf.crt
	$(OPENSSL) x509 -text -noout -in leaf/leaf.crt
verify-leaf: leaf/leaf.crt root/ca.crt
	$(OPENSSL) verify -CAfile root/ca.crt leaf/leaf.crt
check-leaf-crl: root/data/crl/bundle.pem leaf/leaf.crt
	$(OPENSSL) verify -extended_crl -verbose -CAfile root/data/crl/bundle.pem -crl_check leaf/leaf.crt


# LEAF-REVOKED
leaf-revoked/leaf.key:
	$(OPENSSL) genrsa -out $@ 2048
leaf-revoked/leaf.csr: leaf-revoked/leaf.key
	$(OPENSSL) req -config leaf-revoked/csr.conf -new -key leaf-revoked/leaf.key -days $(LEAF_DAYS) -out $@
inspect-leaf-revoked-csr: leaf-revoked/leaf.csr
	$(OPENSSL) req -text -noout -in leaf-revoked/leaf.csr
leaf-revoked/leaf.crt: | leaf-revoked/leaf.csr root/ca.crt $(DATA_DEPS)
	OPENSSL_CONF=$(OPENSSL_CONF) $(OPENSSL) ca -batch \
		-in leaf-revoked/leaf.csr  \
		-extfile leaf-revoked/signing.conf -extensions extensions \
		-out $@ -days $(LEAF_DAYS)
inspect-leaf-revoked: leaf-revoked/leaf.crt
	$(OPENSSL) x509 -text -noout -in leaf-revoked/leaf.crt
check-leaf-revoked-crl: root/data/crl/bundle.pem leaf-revoked/leaf.crt
	-$(OPENSSL) verify -extended_crl -verbose -CAfile root/data/crl/bundle.pem -crl_check leaf-revoked/leaf.crt
revoke: $(GENERATE_DEPS) root/data/crl/crl.pem leaf-revoked/leaf.crt
	OPENSSL_CONF=$(OPENSSL_CONF) $(OPENSSL) \
		ca -revoke leaf-revoked/leaf.crt -crl_reason keyCompromise
	$(GENERATE)


# OCSP
ocsp-signer/ocsp.key:
	$(OPENSSL) genrsa -out $@ 2048
ocsp-signer/ocsp.csr: ocsp-signer/ocsp.key
	$(OPENSSL) req -config ocsp-signer/csr.conf -new -key ocsp-signer/ocsp.key -days $(OCSP_DAYS) -out $@
inspect-ocsp-csr: ocsp-signer/ocsp.csr
	$(OPENSSL) req -text -noout -in ocsp-signer/ocsp.csr
ocsp-signer/ocsp.crt: ocsp-signer/ocsp.csr root/ca.crt
	OPENSSL_CONF=$(OPENSSL_CONF) $(OPENSSL) ca -batch \
		-in ocsp-signer/ocsp.csr  \
		-extfile ocsp-signer/signing.conf -extensions extensions \
		-out $@ -days $(OCSP_DAYS)
inspect-ocsp-signer: ocsp-signer/ocsp.crt
	$(OPENSSL) x509 -text -noout -in ocsp-signer/ocsp.crt
verify-ocsp-signer: ocsp-signer/ocsp.crt root/ca.crt
	$(OPENSSL) verify -CAfile root/ca.crt ocsp-signer/ocsp.crt
test-ocsp-ok: | ocsp-signer/ocsp.crt root/data/index.txt
	$(OPENSSL) ocsp \
			-index root/data/index.txt -port 8080 \
			-rsigner ocsp-signer/ocsp.crt -rkey ocsp-signer/ocsp.key -CA root/ca.crt -out root/data/log.txt & \
		PID=$$!; \
		sleep 1; \
		$(OPENSSL) ocsp \
			-CAfile root/ca.crt -issuer root/ca.crt \
			-cert leaf/leaf.crt -url http://127.0.0.1:8080; \
		kill -TERM $${PID}
test-ocsp-revoked: | ocsp-signer/ocsp.crt root/data/index.txt
	$(OPENSSL) ocsp \
			-index root/data/index.txt -port 8080 \
			-rsigner ocsp-signer/ocsp.crt -rkey ocsp-signer/ocsp.key -CA root/ca.crt -out root/data/log.txt & \
		PID=$$!; \
		sleep 1; \
		$(OPENSSL) ocsp \
			-CAfile root/ca.crt -issuer root/ca.crt \
			-cert leaf-revoked/leaf.crt -url http://127.0.0.1:8080; \
		kill -TERM $${PID}


# CRL
root/data/crl/crl.pem: $(GENERATE_DEPS)
	$(GENERATE)
root/data/crl/bundle.pem: root/data/crl/crl.pem root/ca.crt
	cat root/ca.crt root/data/crl/crl.pem > $@
inspect-crl: root/data/crl/crl.pem
	$(OPENSSL) crl -text -noout -in root/data/crl/crl.pem


# CLEAN
clean-root-key:
	rm -f root/ca.key
clean-root-cert:
	rm -f root/ca.crt
clean-serial:
	rm -f root/ca.srl
clean-leaf-csr:
	rm -f leaf/leaf.csr
clean-leaf-key:
	rm -f leaf/leaf.key
clean-leaf-cert:
	rm -f leaf/leaf.crt
clean-leaf-revoked-csr:
	rm -f leaf-revoked/leaf.csr
clean-leaf-revoked-key:
	rm -f leaf-revoked/leaf.key
clean-leaf-revoked-cert:
	rm -f leaf-revoked/leaf.crt
clean-ocsp:
	rm -f ocsp-signer/ocsp.crt ocsp-signer/ocsp.csr ocsp-signer/ocsp.key
clean-root: clean-root-key clean-root-cert clean-serial
clean-leaf: clean-leaf-csr clean-leaf-key clean-leaf-cert
clean-leaf-revoked: clean-leaf-revoked-csr clean-leaf-revoked-key clean-leaf-revoked-cert
clean-data:
	rm -rf root/data
clean: clean-root clean-leaf clean-leaf-revoked clean-ocsp clean-data
