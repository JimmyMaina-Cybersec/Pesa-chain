# Blockchain/Chaincode/Dockerfile
FROM golang:1.20-alpine

ENV GO111MODULE=on
WORKDIR /chaincode

COPY . .

RUN go mod tidy && go build -o chaincode

EXPOSE 9999

CMD ["./chaincode"]
