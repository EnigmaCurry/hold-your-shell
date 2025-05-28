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

.PHONY: publish # Publish package
publish: clean build
	uv publish

.PHONY: run # Run the program
run:
	uv run python hold_your_shell/hold_your_shell.py

.PHONY: release # Tag and release new version
release:
	@# Check for clean working directory
	@if ! git diff --quiet || ! git diff --cached --quiet; then \
	  echo "[New Release] ✋ Your working directory is not clean. Please commit or stash your changes first."; \
	  exit 1; \
	fi

	@set -e; \
	CURRENT_VERSION=$$(grep -E '^version *= *"' pyproject.toml | sed -E 's/version *= *"(.*)"/\1/'); \
	read -p "[New Release] Enter new version number (current version $$CURRENT_VERSION): " USER_INPUT; \
	if [ -z "$$USER_INPUT" ]; then \
	  echo "[New Release] ❌ No version entered. Aborting."; \
	  exit 1; \
	fi; \
	NEW_VERSION=$$(echo "$$USER_INPUT" | sed -E 's/^v//i'); \
	VTAG="v$$NEW_VERSION"; \
	if git rev-parse "$$VTAG" >/dev/null 2>&1; then \
	  echo "[New Release] ❌ Tag '$$VTAG' already exists. Aborting."; \
	  exit 1; \
	fi; \
	echo "[New Release] Updating pyproject.toml..."; \
	sed -i -E 's/^(version = )".*"/\1"'"$$NEW_VERSION"'"/' pyproject.toml; \
	echo "[New Release] Updating hold_your_shell.py..."; \
	sed -i -E 's/^(__version__ = )".*"/\1"'"$$NEW_VERSION"'"/' hold_your_shell/hold_your_shell.py; \
	uv lock; \
	echo "[New Release] Committing changes..."; \
	git add uv.lock pyproject.toml hold_your_shell/hold_your_shell.py; \
	git commit -m "$$VTAG"; \
	git tag "$$VTAG"; \
	echo "[New Release] ✅ Tagged release: $$VTAG"; \
	read -p "[New Release] Do you want to push the release tag now? [y/N]: " PUSH_TAG; \
	if [ "$$PUSH_TAG" = "y" ] || [ "$$PUSH_TAG" = "Y" ]; then \
	  echo "[New Release] 🚀 Pushing commit and tag..."; \
	  git push && git push --tags; \
	else \
	  echo "[New Release] 💤 Skipped pushing."; \
	fi
