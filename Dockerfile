FROM python:3-alpine

RUN pip install --quiet awscli

RUN aws --version

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
