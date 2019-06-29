#!/usr/bin/env bash

set -o errexit
set -o nounset

readonly SCRIPT_SRC="$(dirname "${BASH_SOURCE[0]}")"
readonly SCRIPT_DIR="$(cd "${SCRIPT_SRC}" >/dev/null 2>&1 && pwd)"
readonly SCRIPT_NAME=$(basename "$0")

main() {
  parse_commandline "$@"

  $show_usage && terminate 3
  validate_requirements && terminate 4

  cd "${SCRIPT_DIR}" && execute_tasks && terminate 5

  terminate 0
}

execute_tasks() {
  $log "Execute tasks"
  execute_build
  return 1
}

execute_build() {
  local -r FILE_PREFIX="body"

  local -r FILE_SRC="${FILE_PREFIX}.md"
  local -r FILE_TEX="${FILE_PREFIX}.tex"
  local -r FILE_PDF="${FILE_PREFIX}.pdf"
  local -r FILE_DST="output.pdf"

  $log "Concatenate files to ${FILE_SRC}"
  cat ./??.md > "${FILE_SRC}"

  if [ "$docker" = true ] ; then
    $log "Generate ${FILE_TEX} via Docker Container"  
    docker run --rm -v `pwd`:/app -w /app minidocks/pandoc pandoc --standalone --to context "${FILE_SRC}" \
      > "${FILE_TEX}"

    $log "Generate ${FILE_PDF} via Docker Container"
    docker run --rm -v ${PWD}:/my-doc -w /my-doc grummfy/context-docker context --nonstopmode --batchmode --purgeall "${FILE_TEX}" \
      > /dev/null 2>&1
  else 
    $log "Generate ${FILE_TEX}"
    pandoc --standalone --to context "${FILE_SRC}" \
      > "${FILE_TEX}"

    $log "Generate ${FILE_PDF}"
    context --nonstopmode --batchmode --purgeall "${FILE_TEX}" \
      > /dev/null 2>&1
  fi

  $log "Rename ${FILE_PDF} to ${FILE_DST}"
  mv "${FILE_PDF}" "${FILE_DST}"

}

validate_requirements() {
  $log "Check missing software requirements"

  required context "https://wiki.contextgarden.net"
  required pandoc "https://www.pandoc.org"
  required gs "https://www.ghostscript.com"

  return "${REQUIRED_MISSING}"
}

required() {
  if ! command -v "$1" > /dev/null 2>&1; then
    warning "Missing requirement: install $1 ($2)"
    REQUIRED_MISSING=0
  fi
}

utile_show_usage() {
  printf "Usage: %s [OPTION...]\n" "${SCRIPT_NAME}" >&2
  printf "  -d, --debug\t\tLog messages while processing\n" >&2
  printf "  -h, --help\t\tShow this help message then exit\n" >&2

  return 0
}

coloured_text() {
  printf "%b%s%b\n" "$2" "$1" "${COLOUR_OFF}"
}

warning() {
  coloured_text "$1" "${COLOUR_WARNING}"
}

error() {
  coloured_text "$1" "${COLOUR_ERROR}"
}

utile_log() {
  printf "[%s] " "$(date +%H:%I:%S.%4N)"
  coloured_text "$1" "${COLOUR_LOGGING}"
}

noop() {
  return 1
}

terminate() {
  exit "$1"
}

parse_commandline() {
  while [ "$#" -gt "0" ]; do
    local consume=1

    case "$1" in
      -d|--debug)
        log=utile_log
      ;;
      -h|-\?|--help)
        show_usage=utile_show_usage
      ;;
      -c|--container|--docker)
        docker=true
      ;;
      *)
        # Skip argument
      ;;
    esac

    shift ${consume}
  done
}

# ANSI colour escape sequences.
readonly COLOUR_BLUE='\033[1;34m'
readonly COLOUR_PINK='\033[1;35m'
readonly COLOUR_DKGRAY='\033[30m'
readonly COLOUR_DKRED='\033[31m'
readonly COLOUR_YELLOW='\033[1;33m'
readonly COLOUR_OFF='\033[0m'

# Colour definitions used by script.
readonly COLOUR_LOGGING=${COLOUR_BLUE}
readonly COLOUR_WARNING=${COLOUR_YELLOW}
readonly COLOUR_ERROR=${COLOUR_DKRED}

# Set to 0 if any commands are missing.
REQUIRED_MISSING=1

# These functions may be set to utile delegates while parsing arguments.
show_usage=noop
log=noop
docker=false

main "$@"

