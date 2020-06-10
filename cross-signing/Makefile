# Optionall override days
ROOT_DAYS ?= 365
INTERMEDIATE_DAYS ?= 365
LEAF_DAYS ?= 365
NO_OPTS = no_subject,no_header,no_version,no_serial,no_signame,no_validity,no_issuer,no_pubkey,no_sigdump,no_aux

# Optionally override which openssl version to use
OPENSSL ?= openssl

help:
	@echo "Available targets:\n"
	@grep '^[^#[:space:]]\+:' Makefile \
		| awk -F: '{ print $$1 }' \
		| sort

all: verify
bundle-1.crt: root-1/ca.crt intermediates/ca-1.crt
	cat root-1/ca.crt intermediates/ca-1.crt > $@
bundle-2.crt: root-2/ca.crt intermediates/ca-2.crt
	cat root-2/ca.crt intermediates/ca-2.crt > $@
bundles: bundle-1.crt bundle-2.crt
verify: bundles leaf/leaf.crt
	$(OPENSSL) verify -CAfile bundle-1.crt leaf/leaf.crt
	$(OPENSSL) verify -CAfile bundle-2.crt leaf/leaf.crt
inspect: inspect-root-1 inspect-root-2 inspect-intermediate-1 inspect-intermediate-2 inspect-leaf
inspect-extensions: root-1/ca.crt root-2/ca.crt intermediates/ca-1.crt intermediates/ca-2.crt leaf/leaf.crt
	@echo "ROOT 1":
	@$(OPENSSL) x509 -in root-1/ca.crt -text -certopt $(NO_OPTS) -noout
	@echo
	@echo "ROOT 2":
	@$(OPENSSL) x509 -in root-2/ca.crt -text -certopt $(NO_OPTS) -noout
	@echo
	@echo "INTERMEDIATE 1":
	@$(OPENSSL) x509 -in intermediates/ca-1.crt -text -certopt $(NO_OPTS) -noout
	@echo
	@echo "INTERMEDIATE 2":
	@$(OPENSSL) x509 -in intermediates/ca-2.crt -text -certopt $(NO_OPTS) -noout
	@echo
	@echo "LEAF":
	@$(OPENSSL) x509 -in leaf/leaf.crt -text -certopt $(NO_OPTS) -noout

# ROOT 1
root-1/ca.key:
	$(OPENSSL) genrsa -out $@ 2048
root-1/ca.crt: root-1/ca.key
	$(OPENSSL) req -config root-1/ca.conf -x509 -new -key root-1/ca.key -days $(ROOT_DAYS) -out $@
inspect-root-1: root-1/ca.crt
	$(OPENSSL) x509 -text -noout -in root-1/ca.crt

# ROOT 2
root-2/ca.key:
	$(OPENSSL) genrsa -out $@ 2048
root-2/ca.crt: root-2/ca.key
	$(OPENSSL) req -config root-2/ca.conf -x509 -new -key root-2/ca.key -days $(ROOT_DAYS) -out $@
inspect-root-2: root-2/ca.crt
	$(OPENSSL) x509 -text -noout -in root-2/ca.crt

# INTERMEDIATES
intermediates/ca.key:
	$(OPENSSL) genrsa -out $@ 2048
intermediates/ca.csr: intermediates/ca.key
	$(OPENSSL) req -config intermediates/csr.conf -new -key intermediates/ca.key -days $(INTERMEDIATE_DAYS) -out $@
intermediates/ca-1.crt: intermediates/ca.csr root-1/ca.crt
	$(OPENSSL) x509 \
		-req -in intermediates/ca.csr -CA root-1/ca.crt -CAkey root-1/ca.key -CAcreateserial \
		-extfile intermediates/signing.conf -extensions extensions \
		-sha256 -out $@ -days $(INTERMEDIATE_DAYS)
intermediates/ca-2.crt: intermediates/ca.csr root-2/ca.crt
	$(OPENSSL) x509 \
		-req -in intermediates/ca.csr -CA root-2/ca.crt -CAkey root-2/ca.key -CAcreateserial \
		-extfile intermediates/signing.conf -extensions extensions \
		-sha256 -out $@ -days $(INTERMEDIATE_DAYS)
inspect-intermediate-csr: intermediates/ca.csr
	$(OPENSSL) req -text -noout -in intermediates/ca.csr
inspect-intermediate-1: intermediates/ca-1.crt
	$(OPENSSL) x509 -text -noout -in intermediates/ca-1.crt
inspect-intermediate-2: intermediates/ca-2.crt
	$(OPENSSL) x509 -text -noout -in intermediates/ca-2.crt

# LEAF
leaf/leaf.key:
	$(OPENSSL) genrsa -out $@ 2048
leaf/leaf.csr: leaf/leaf.key
	$(OPENSSL) req -config leaf/csr.conf -new -key leaf/leaf.key -days $(LEAF_DAYS) -out $@
leaf/leaf.crt: leaf/leaf.csr intermediates/ca-1.crt
	$(OPENSSL) x509 \
		-req -in leaf/leaf.csr -CA intermediates/ca-1.crt -CAkey intermediates/ca.key -CAcreateserial \
		-extfile leaf/signing.conf -extensions extensions \
		-sha256 -out $@ -days $(LEAF_DAYS)
inspect-leaf-csr: leaf/leaf.csr
	$(OPENSSL) req -text -noout -in leaf/leaf.csr
inspect-leaf: leaf/leaf.crt
	$(OPENSSL) x509 -text -noout -in leaf/leaf.crt

# CLEAN
clean-bundles:
	rm -f bundle-1.crt bundle-2.crt
clean-roots:
	rm -f \
		root-1/ca.crt root-1/ca.key root-1/ca.srl \
		root-2/ca.crt root-2/ca.key root-2/ca.srl
clean-intermediates:
	rm -f \
		intermediates/ca.key intermediates/ca.csr \
		intermediates/ca-1.crt intermediates/ca-1.srl \
		intermediates/ca-2.crt intermediates/ca-2.srl
clean-leaf: clean-leaf-key clean-leaf-csr clean-leaf-cert
clean-leaf-csr:
	rm -f leaf/leaf.csr
clean-leaf-key:
	rm -f leaf/leaf.key
clean-leaf-cert:
	rm -f leaf/leaf.crt
clean: clean-roots clean-intermediates clean-leaf clean-bundles
