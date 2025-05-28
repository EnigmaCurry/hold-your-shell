# Release

To make a new release, run:

```
make release
```

Enter the new version number when asked, and it will simultaneously
update `pyproject.toml` and `hold_your_shell.py` with the new version
and git tag the release. If you push the tag, the
[publish.yml](.github/workflows/publish.yml) workflow will trigger a
new release upload to PyPI.
