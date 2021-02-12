CA_FILE=ca.key
PRIVATE_KEY=id
SIGNED_CERT=$(PRIVATE_KEY)-cert.pub

help:
	@echo "Available targets:\n"
	@grep '^[^.#[:space:]]\+:' Makefile \
		| grep -v '^\$$' \
		| awk -F: '{ print $$1 }' \
		| sort

all: $(SIGNED_CERT)

$(CA_FILE):
	ssh-keygen -f $(CA_FILE) -C "CA: myca" -b 4096 -V '-1d:+365d' -N ''

$(PRIVATE_KEY): $(CA_FILE)
	ssh-keygen -f $(PRIVATE_KEY) -C "My Unsigned Key" -b 4096 -V '-1d:+365d' -N ''

$(SIGNED_CERT): $(PRIVATE_KEY)
	ssh-keygen -I "Signed by myca" -n "group1,group2" -s $(CA_FILE) -V '+1h' -z $$(date '+%s') $(PRIVATE_KEY).pub

inspect: $(SIGNED_CERT)
	ssh-keygen -L -f $(SIGNED_CERT)

clean:
	rm -f $(CA_FILE) $(CA_FILE).pub $(PRIVATE_KEY) $(PRIVATE_KEY).pub $(SIGNED_CERT)
