FROM alpine:latest

RUN apk add --update openssh bash vim
RUN adduser --disabled-password -s /bin/bash test-user
RUN passwd -u test-user
RUN mkdir -p /etc/ssh/authorized_principals

ADD docker/entrypoint.sh /entrypoint.sh

EXPOSE 22
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/sbin/sshd","-D","-e"]
