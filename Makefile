include .env
export

PROJECT_NAME="rinha-2024-q1"
BIN_DIR=bin
TARGET=$(BIN_DIR)/$(PROJECT_NAME)

.PHONY: dev prod test test-only

dev: $(TARGET)
	@v -o $(TARGET) watch -d debug -d trace_orm --silent --clear run .

build: $(TARGET)
	@v . -prod -o $(TARGET)

build-clang: $(TARGET)
	@v . -prod -cc clang -o $(TARGET)

run: $(TARGET)
	@$(TARGET)

test: $(TARGET)
	@v test .

test-only: $(TARGET)
	@v test ./$(name)

$(TARGET):
	@mkdir -p $(BIN_DIR)
