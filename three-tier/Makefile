# Optionall override days
ROOT_DAYS ?= 365
INTERMEDIATE_DAYS ?= 365
LEAF_DAYS ?= 365

# Optionally override which openssl version to use
OPENSSL ?= openssl

help:
	@echo "Available targets:\n"
	@grep '^[^#[:space:]]\+:' Makefile \
		| awk -F: '{ print $$1 }' \
		| sort

all: verify
version:
	$(OPENSSL) version
verify: leaf/leaf.crt bundle.crt
	$(OPENSSL) verify -CAfile bundle.crt leaf/leaf.crt
bundle.crt: root/ca.crt intermediate/ca.crt
	cat root/ca.crt intermediate/ca.crt > bundle.crt
inspect: inspect-root inspect-intermediate inspect-leaf
inspect-extensions: root/ca.crt intermediate/ca.crt leaf/leaf.crt
	@echo "ROOT":
	@$(OPENSSL) x509 -in root/ca.crt -text -certopt no_subject,no_header,no_version,no_serial,no_signame,no_validity,no_issuer,no_pubkey,no_sigdump,no_aux -noout
	@echo
	@echo "INTERMEDIATE":
	@$(OPENSSL) x509 -in intermediate/ca.crt -text -certopt no_subject,no_header,no_version,no_serial,no_signame,no_validity,no_issuer,no_pubkey,no_sigdump,no_aux -noout
	@echo
	@echo "LEAF":
	@$(OPENSSL) x509 -in leaf/leaf.crt -text -certopt no_subject,no_header,no_version,no_serial,no_signame,no_validity,no_issuer,no_pubkey,no_sigdump,no_aux -noout

# ROOT
root/ca.key:
	$(OPENSSL) genrsa -out $@ 2048
root/ca.crt: root/ca.key
	$(OPENSSL) req -config root/ca.conf -x509 -new -key root/ca.key -days $(ROOT_DAYS) -out $@
inspect-root: root/ca.crt
	$(OPENSSL) x509 -text -noout -in root/ca.crt

# INTERMEDIATE
intermediate/ca.key:
	$(OPENSSL) genrsa -out $@ 2048
intermediate/ca.csr: intermediate/ca.key
	$(OPENSSL) req -config intermediate/csr.conf -new -key intermediate/ca.key -days $(INTERMEDIATE_DAYS) -out $@
intermediate/ca.crt: intermediate/ca.csr root/ca.crt
	$(OPENSSL) x509 \
		-req -in intermediate/ca.csr -CA root/ca.crt -CAkey root/ca.key -CAcreateserial \
		-extfile intermediate/signing.conf -extensions extensions \
		-sha256 -out $@ -days $(INTERMEDIATE_DAYS)
inspect-intermediate-csr: intermediate/ca.csr
	$(OPENSSL) req -text -noout -in intermediate/ca.csr
inspect-intermediate: intermediate/ca.crt
	$(OPENSSL) x509 -text -noout -in intermediate/ca.crt

# LEAF
leaf/leaf.key:
	$(OPENSSL) genrsa -out $@ 2048
leaf/leaf.csr: leaf/leaf.key
	$(OPENSSL) req -config leaf/csr.conf -new -key leaf/leaf.key -days $(LEAF_DAYS) -out $@
leaf/leaf.crt: leaf/leaf.csr intermediate/ca.crt
	$(OPENSSL) x509 \
		-req -in leaf/leaf.csr -CA intermediate/ca.crt -CAkey intermediate/ca.key -CAcreateserial \
		-extfile leaf/signing.conf -extensions extensions \
		-sha256 -out $@ -days $(LEAF_DAYS)
inspect-leaf-csr: leaf/leaf.csr
	$(OPENSSL) req -text -noout -in leaf/leaf.csr
inspect-leaf: leaf/leaf.crt
	$(OPENSSL) x509 -text -noout -in leaf/leaf.crt


# CLEAN
clean-bundle:
	rm -f bundle.crt
clean-root: clean-root-key clean-root-cert clean-root-serial
clean-root-key:
	rm -f root/ca.key
clean-root-cert:
	rm -f root/ca.crt
clean-root-serial:
	rm -f root/ca.srl
clean-intermediate: clean-intermediate-key clean-intermediate-cert clean-intermediate-serial
clean-intermediate-key:
	rm -f intermediate/ca.key
clean-intermediate-cert:
	rm -f intermediate/ca.crt
clean-intermediate-csr:
	rm -f intermediate/ca.csr
clean-intermediate-serial:
	rm -f intermediate/ca.srl
clean-leaf: clean-leaf-key clean-leaf-csr clean-leaf-cert
clean-leaf-csr:
	rm -f leaf/leaf.csr
clean-leaf-key:
	rm -f leaf/leaf.key
clean-leaf-cert:
	rm -f leaf/leaf.crt
clean: clean-root clean-intermediate clean-leaf clean-bundle
