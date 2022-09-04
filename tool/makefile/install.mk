.PHONY: install codegen

install: codegen format

codegen: get
	@echo "Running codegeneration"
	@dart run build_runner build --delete-conflicting-outputs --release
