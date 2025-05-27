.PHONY: help # Show this help screen
help:
	@grep -h '^.PHONY: .* #' Makefile | sed 's/\.PHONY: \(.*\) # \(.*\)/make \1 \t- \2/' | expand -t20

.PHONY: clean # Clean all build artifacts
clean:
	rm -rf dist hold_your_shell.egg-info
	uv clean

.PHONY: deps # Check for required dependencies
deps:
	@command -v uv >/dev/null 2>&1 && echo "✔ 'uv' is installed." || (echo -e "✘ 'uv' is not installed.\n\nPlease install uv :: https://docs.astral.sh/uv/\n"; exit 1)

.PHONY: build # Build package
build: deps
	uv build

