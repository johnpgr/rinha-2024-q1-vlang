include .env
export

PROJECT_NAME="rinha-2024-q1"
BIN_DIR=bin
SRC_DIR=src
TARGET=$(BIN_DIR)/$(PROJECT_NAME)

.PHONY: dev prod test test-only

dev: $(TARGET)
	@v -o $(TARGET) watch -d trace_orm --silent --clear run ./$(SRC_DIR)

build: $(TARGET)
	@v ./$(SRC_DIR) -prod -o $(TARGET)

build-clang: $(TARGET)
	@v ./$(SRC_DIR) -prod -cc clang -o $(TARGET)

run: $(TARGET)
	@$(TARGET)

test: $(TARGET)
	@v test ./$(SRC_DIR)

test-only: $(TARGET)
	@v test ./$(SRC_DIR)/$(name)

$(TARGET):
	@mkdir -p $(BIN_DIR)
