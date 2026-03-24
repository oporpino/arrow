# Terminal formatting — only emit escape codes when stdout is a real terminal
if [[ -t 1 ]]; then
  readonly BOLD="\033[1m"
  readonly DIM="\033[2m"
  readonly ITALIC="\033[3m"
  readonly RED="\033[1;31m"
  readonly GREEN="\033[1;32m"
  readonly YELLOW="\033[1;33m"
  readonly BLUE="\033[1;34m"
  readonly MAGENTA="\033[1;35m"
  readonly CYAN="\033[1;36m"
  readonly WHITE="\033[1;37m"
  readonly DIM_CYAN="\033[2;36m"
  readonly DIM_WHITE="\033[2;37m"
  readonly RESET="\033[0m"
else
  # shellcheck disable=SC2034
  BOLD="" DIM="" ITALIC="" RED="" GREEN="" YELLOW="" BLUE=""
  MAGENTA="" CYAN="" WHITE="" DIM_CYAN="" DIM_WHITE="" RESET=""
fi
