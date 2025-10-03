BIN_NAME=pulse

# 👇 Build the binary (production)
.PHONY: build
build: tidy
	@CGO_ENABLED=0 GOEXPERIMENT=greenteagc go build -trimpath -tags=production -ldflags "-s -w" -o bin/$(BIN_NAME) cmd/app/main.go
	@echo "Build complete!"

# 👇 Shared logic for building
.PHONY: tidy
tidy:
	@go mod tidy
	@echo "Building $(BIN_NAME)..."

# 👇 Run the binary
.PHONY: run
run:
	@./bin/$(BIN_NAME)

# 👇 Dev mode with Swagger + formatting
.PHONY: dev
dev: fmt docs
	@go run cmd/app/main.go

# 👇 Create Swagger docs
.PHONY: docs
docs:
	@swag init -g internal/app/main.go --output internal/app/docs

# 👇 Format code & Swagger
.PHONY: fmt
fmt:
	@echo "Formatting swagger docs..."
	@swag fmt

# 👇 Clean binary output
.PHONY: clean
clean:
	@echo "Cleaning up..."
	@go clean
	@rm -rf bin/