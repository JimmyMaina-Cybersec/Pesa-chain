# Stage 1: Build the chaincode
FROM golang:1.20-alpine AS builder

# Set environment variables
ARG ENV=production
ENV GO111MODULE=on \
    GOPROXY=https://proxy.golang.org

# Set the working directory
WORKDIR /chaincode

# Copy the Go modules files and download dependencies
COPY go.mod go.sum ./
RUN go mod download

# Copy the rest of the chaincode source code
COPY . .

# Build the chaincode binary with flags based on the environment
RUN if [ "$ENV" = "development" ]; then \
      go build -gcflags "all=-N -l" -o chaincode; \
    else \
      go build -o chaincode; \
    fi

# Stage 2: Create a lean image for the chaincode
FROM alpine:latest

# Set the working directory
WORKDIR /chaincode

# Copy the compiled binary from the builder stage
COPY --from=builder /chaincode/chaincode /chaincode/chaincode

# Command to run the chaincode
CMD ["./chaincode"]
