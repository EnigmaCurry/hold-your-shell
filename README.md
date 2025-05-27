# hold-your-shell

`hold-your-shell` is a command line program (TUI) that previews shell
scripts (or any shebang script) in a pager, and asks the user to
confirm execution.

This single file program is written for Python 3.x and only uses the
stdlib.

![image](https://github.com/user-attachments/assets/b7ac2a36-b97d-4c96-b33e-f0d2bfbfde3b)

## Install

Pip install:

```
pip install hold-your-shell
```

Manual install:

```
HY_BIN=~/.local/bin/hold-your-shell
mkdir -p $(dirname ${HY_BIN})

wget -O ${HY_BIN} https://raw.githubusercontent.com/EnigmaCurry/hold-your-shell/refs/heads/master/hold_your_shell/hold_your_shell.py

chmod +x ${HY_BIN}
```

## Examples

```
echo "whoami" | hold-your-shell
```

```
cat <<'EOF' | hold-your-shell
echo "What is your name?"
read NAME
echo "Hello $NAME"
EOF
```

```
curl https://get.docker.com/ | hold-your-shell
```
