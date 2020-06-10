OPENSSL ?= openssl
HTTPS_PORT ?= 443

help:
	@grep '^[^#[:space:]].\+:' Makefile \
		| awk -F: '{ print $$1 }' \
		| sort

https-%:
	echo | $(OPENSSL) s_client -servername $(*) -showcerts -connect $(*):$(HTTPS_PORT) \
		| openssl x509 -text
