FROM node:16.13.2-alpine

WORKDIR /app

RUN npm install -g ganache-cli

# ganache-cli docker instance 기본 호스트 0.0.0.0
CMD ["ganache-cli", "-h", "0.0.0.0"]