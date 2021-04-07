CA_FILE=ca.key
PRIVATE_KEY=id
SIGNED_CERT=$(PRIVATE_KEY)-cert.pub
IMAGE_NAME=test-ssh-server

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

build-ssh-server:
	docker build --no-cache -t $(IMAGE_NAME):latest .

run-ssh-server: $(CA_FILE)
	docker run \
		--rm \
		--name $(IMAGE_NAME) \
		-v ${PWD}/docker/sshd_config:/etc/ssh/sshd_config \
		-v ${PWD}/docker/test-user:/etc/ssh/authorized_principals/test-user \
		-v ${PWD}/$(CA_FILE).pub:/etc/ssh/ca.pub \
		-p 22:22 \
		$(IMAGE_NAME)

rm-ssh-server:
	-docker rm -f $(IMAGE_NAME)

test-ssh-client: $(SIGNED_CERT)
	ssh \
		-o UserKnownHostsFile=/dev/null \
		-o StrictHostKeyChecking=no \
		-i $(PRIVATE_KEY) \
		test-user@localhost echo "I connected successfully!"

start-console:
	docker run --entrypoint /bin/bash --rm -it $(IMAGE_NAME)

console:
	docker exec -it $(IMAGE_NAME) bash

clean:
	rm -f $(CA_FILE) $(CA_FILE).pub $(PRIVATE_KEY) $(PRIVATE_KEY).pub $(SIGNED_CERT)
