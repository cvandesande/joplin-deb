#!/usr/bin/env bash

set -e
if [ $# -eq 0 ]; then
    printf "Usage: joplin-deb.sh version\nExample: ./joplin-deb.sh 2.5.12\n"
    exit 1
fi

box_out()
{
  local s=("$@") b w
  for l in "${s[@]}"; do
    ((w<${#l})) && { b="$l"; w="${#l}"; }
  done
  tput setaf 3
  echo " -${b//?/-}-
| ${b//?/ } |"
  for l in "${s[@]}"; do
    printf '| %s%*s%s |\n' "$(tput setaf 4)" "-$w" "$l" "$(tput setaf 3)"
  done
  echo "| ${b//?/ } |
 -${b//?/-}-"
  tput sgr 0
}

docker pull node:lts-bullseye-slim
docker build . --build-arg VERSION=$1 -t joplin-deb
docker run \
    --rm \
    --name joplin-deb \
    -v ${HOME}/Downloads:/usr/src/app/Downloads \
    joplin-deb /bin/bash -c "VERSION=$1 export.sh"

box_out "Build complete!" \
    "Joplin deb package saved to ${HOME}/Downloads/joplin_$1_amd64.deb" \
    "Install with:" \
    "sudo dpkg -i ~/Downloads/joplin_$1_amd64.deb" \
    "Or with your package manager of choice"
