#!/usr/bin/env bash

set -e
export LC_ALL=C

__info() { __log 'INFO' $1; }
__debug() { __log 'DEBUG' $1; }
__warn() { __log 'WARN' $1; }
__notice() { __log 'NOTICE' $1; }
__error() { __log 'ERROR' $1; exit 1; }
__log() {
     local level=${1?}
     shift
     local code= line="[$(date '+%F %T')] $level: $*"
     if [ -t 2 ]
     then
         case "$level" in
         INFO) code=36 ;;
         DEBUG) code=30 ;;
         WARN) code=33 ;;
         ERROR) code=31 ;;
         *) code=37 ;;
         esac
         echo -e "\e[${code}m${line}\e[0m"
     else
         echo "$line"
     fi >&2
}

usage()
{
cat << EOF
usage: $0 -j 2.8.8 [-o ~/tmpdir]

OPTIONS:
   -h     Show this message
   -j     Joplin version to build
  [-o     Output directory]
EOF

exit 1
}

control_c()
{
  __error "Received interrupt, exiting..."
  exit $?
}

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

trap control_c INT SIGHUP SIGINT SIGTERM

while getopts "hj:o:" OPTION
do
     case $OPTION in
         h)
            usage
            exit 1
            ;;
         j)
            _versionToBuild=$OPTARG
            ;;
         o)
            _outputDirectory=$OPTARG
            ;;
         ?)  
             usage
             exit 1
             ;;
     esac
done

[ -z "${_versionToBuild}" ] && usage
[ -z "${_outputDirectory}" ] && _outputDirectory="${HOME}/tmpdir" && __info "Using ${_outputDirectory} as output directory"
[ ! -d "${_outputDirectory}" ] && mkdir -p "${_outputDirectory}" && __info "Creating ${_outputDirectory} directory"

if [ -f "$(command -v podman)" -a -x "$(command -v podman)" ]; then
    _containersUtil=$(command -v podman)
elif [ -f "$(command -v docker)" -a -x "$(command -v docker)" ]; then
    _containersUtil=$(command -v docker)
else 
    __error  "Cannot find either podman or docker util"
fi

${_containersUtil} pull node:lts-bullseye-slim
${_containersUtil} build . --build-arg VERSION=${_versionToBuild} -t joplin-deb
${_containersUtil} run \
    --rm \
    --name joplin-deb \
    -v ${_outputDirectory}:/usr/src/app/Downloads \
    joplin-deb /bin/bash -c "VERSION=${_versionToBuild} export.sh"

box_out "Build complete!" \
    "Joplin deb package saved to ${_outputDirectory}/joplin_${_versionToBuild}_amd64.deb" \
    "Install with:" \
    "sudo dpkg -i ~/Downloads/joplin_${_versionToBuild}_amd64.deb" \
    "Or with your package manager of choice"
