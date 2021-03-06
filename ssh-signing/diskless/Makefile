help:
	@echo "Available targets:\n"
	@grep '^[^.#[:space:]]\+:' Makefile \
		| grep -v '^\$$' \
		| awk -F: '{ print $$1 }' \
		| sort

create-and-sign:
	@./create-and-sign.sh
sign-and-inspect:
	./create-and-sign.sh | jq -r .user_public_key_signed > user-cert.pub
	ssh-keygen -Lf user-cert.pub
	rm -f user-cert.pub
