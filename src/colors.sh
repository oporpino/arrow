# Terminal formatting — only emit escape codes when stdout is a real terminal
if [[ -t 1 ]]; then
  readonly BOLD="\033[1m"
  readonly DIM="\033[2m"
  readonly RED="\033[1;31m"
  readonly GREEN="\033[1;32m"
  readonly YELLOW="\033[1;33m"
  readonly CYAN="\033[1;36m"
  readonly BLUE="\033[1;34m"
  readonly RESET="\033[0m"
else
  # shellcheck disable=SC2034
  BOLD="" DIM="" RED="" GREEN="" YELLOW="" CYAN="" BLUE="" RESET=""
fi
