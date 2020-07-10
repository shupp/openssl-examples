# Optionall override days
ROOT_DAYS ?= 365

# Optionally override which openssl version to use
OPENSSL ?= openssl

CERT_OPTS = no_subject,no_header,no_version,no_serial,no_signame,no_validity,no_issuer,no_pubkey,no_sigdump,no_aux

help:
	@echo "Available targets:\n"
	@grep '^[^#[:space:]]\+:' Makefile \
		| awk -F: '{ print $$1 }' \
		| sort

prep: root/ca.crt

all:
	@echo "Inspecting x509v3 Extensions from the Cert:"
	@$(MAKE) inspect-root-extensions
	@echo
	@echo "Generated Subject Key Identifier from Cert:"
	@$(MAKE) generate-ski-from-cert
	@echo
	@echo "Generated Subject Key Identifier from Private Key:"
	@$(MAKE) generate-ski-from-private-key

# ROOT
root/ca.key:
	$(OPENSSL) genrsa -out $@ 2048
root/ca.crt: root/ca.key
	$(OPENSSL) req -config root/ca.conf -x509 -new -key $< -days $(ROOT_DAYS) -out $@
inspect-root: root/ca.crt
	$(OPENSSL) x509 -text -noout -in $<
inspect-root-extensions: root/ca.crt
	@$(OPENSSL) x509 -text -certopt $(CERT_OPTS) -noout -in $<

# SKI PARSING
parse-ski-from-pubkey-input:
	@TEMP=$$(mktemp); \
		echo "$$(cat /dev/stdin)" | $(OPENSSL) asn1parse -strparse 19 -out $${TEMP} >/dev/null; \
		$(OPENSSL) dgst -c -sha1 $${TEMP} \
			| awk '{ print $$2 }' \
			| tr '[:lower:]' '[:upper:]'; \
		rm -f $${TEMP}
generate-ski-from-cert: root/ca.crt
	@$(OPENSSL) x509 -pubkey -noout -in $< \
		| $(MAKE) parse-ski-from-pubkey-input
generate-ski-from-private-key: root/ca.key
	@$(OPENSSL) rsa -pubout -in $< 2>/dev/null \
		| $(MAKE) parse-ski-from-pubkey-input

clean:
	rm -f root/ca.key root/ca.crt
