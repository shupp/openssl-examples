.PHONY: crl/bundle.pem revoke

# Optionall override days
ROOT_DAYS ?= 365
LEAF_DAYS ?= 365

# Optionally override which openssl version to use
OPENSSL ?= openssl
GENERATE_DEPS = root/ca.crt root/ca.key crl/index.txt crl/number
GENERATE = $(OPENSSL) ca -gencrl -keyfile root/ca.key -cert root/ca.crt -out crl/crl.pem -config crl/crl.conf
CERT_OPTS = no_subject,no_header,no_version,no_serial,no_signame,no_validity,no_issuer,no_pubkey,no_sigdump,no_aux

help:
	@echo "Available targets:\n"
	@grep '^[^.#[:space:]]\+:' Makefile \
		| awk -F: '{ print $$1 }' \
		| sort

prep: leaf/leaf.crt leaf-revoked/leaf.crt crl/bundle.pem

version:
	$(OPENSSL) version

inspect-extensions: root/ca.crt leaf/leaf.crt leaf-revoked/leaf.crt
	@echo "ROOT":
	@$(OPENSSL) x509 -in root/ca.crt -text -certopt $(CERT_OPTS) -noout
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
	$(OPENSSL) req -config root/ca.conf -x509 -new -key root/ca.key -days $(ROOT_DAYS) -out $@
inspect-root: root/ca.crt
	$(OPENSSL) x509 -text -noout -in root/ca.crt

# LEAF
leaf/leaf.key:
	$(OPENSSL) genrsa -out $@ 2048
leaf/leaf.csr: leaf/leaf.key
	$(OPENSSL) req -config leaf/csr.conf -new -key leaf/leaf.key -days $(LEAF_DAYS) -out $@
inspect-leaf-csr: leaf/leaf.csr
	$(OPENSSL) req -text -noout -in leaf/leaf.csr
leaf/leaf.crt: leaf/leaf.csr root/ca.crt
	$(OPENSSL) x509 \
		-req -in leaf/leaf.csr -CA root/ca.crt -CAkey root/ca.key -CAcreateserial \
		-extfile leaf/signing.conf -extensions extensions \
		-sha256 -out $@ -days $(LEAF_DAYS)
inspect-leaf: leaf/leaf.crt
	$(OPENSSL) x509 -text -noout -in leaf/leaf.crt
verify-leaf: leaf/leaf.crt root/ca.crt
	$(OPENSSL) verify -CAfile root/ca.crt leaf/leaf.crt
check-leaf-crl: crl/bundle.pem leaf/leaf.crt
	$(OPENSSL) verify -extended_crl -verbose -CAfile crl/bundle.pem -crl_check leaf/leaf.crt


# LEAF-REVOKED
leaf-revoked/leaf.key:
	$(OPENSSL) genrsa -out $@ 2048
leaf-revoked/leaf.csr: leaf-revoked/leaf.key
	$(OPENSSL) req -config leaf-revoked/csr.conf -new -key leaf-revoked/leaf.key -days $(LEAF_DAYS) -out $@
inspect-leaf-revoked-csr: leaf-revoked/leaf.csr
	$(OPENSSL) req -text -noout -in leaf-revoked/leaf.csr
leaf-revoked/leaf.crt: leaf-revoked/leaf.csr root/ca.crt
	$(OPENSSL) x509 \
		-req -in leaf-revoked/leaf.csr -CA root/ca.crt -CAkey root/ca.key -CAcreateserial \
		-extfile leaf-revoked/signing.conf -extensions extensions \
		-sha256 -out $@ -days $(LEAF_DAYS)
inspect-leaf-revoked: leaf-revoked/leaf.crt
	$(OPENSSL) x509 -text -noout -in leaf-revoked/leaf.crt
check-leaf-revoked-crl: crl/bundle.pem leaf-revoked/leaf.crt
	-$(OPENSSL) verify -extended_crl -verbose -CAfile crl/bundle.pem -crl_check leaf-revoked/leaf.crt
revoke: $(GENERATE_DEPS) crl/crl.pem leaf-revoked/leaf.crt
	$(OPENSSL) ca -revoke leaf-revoked/leaf.crt -keyfile root/ca.key -cert root/ca.crt -config crl/crl.conf -crl_reason keyCompromise
	$(GENERATE)

# CRL
crl/index.txt:
	touch crl/index.txt
crl/number:
	echo 00 > crl/number
crl/crl.pem: $(GENERATE_DEPS)
	$(GENERATE)
crl/bundle.pem: crl/crl.pem root/ca.crt
	cat root/ca.crt crl/crl.pem > crl/bundle.pem
inspect-crl: crl/crl.pem
	$(OPENSSL) crl -text -noout -in crl/crl.pem


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
clean-crl:
	rm -f crl/index.txt* crl/crl.pem crl/number* crl/bundle.pem
clean-root: clean-root-key clean-root-cert clean-serial
clean-leaf: clean-leaf-csr clean-leaf-key clean-leaf-cert
clean-leaf-revoked: clean-leaf-revoked-csr clean-leaf-revoked-key clean-leaf-revoked-cert
clean: clean-root clean-leaf clean-leaf-revoked clean-crl
