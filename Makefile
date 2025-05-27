.PHONY: help # Show this help screen
help:
	@grep -h '^.PHONY: .* #' Makefile | sed 's/\.PHONY: \(.*\) # \(.*\)/make \1 \t- \2/' | expand -t20

.PHONY: deps # Check for required dependencies
deps:
	@command -v uvz >/dev/null 2>&1 && echo "✔ 'uv' is installed." || (echo -e "✘ 'uv' is not installed.\n\nPlease install uv :: https://docs.astral.sh/uv/\n"; exit 1)

.PHONY: build # Build package
build:

