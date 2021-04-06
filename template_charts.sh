#!/bin/bash
# templates and updates helm charts; assumes chart-of-charts structure
# and an override environment directory, which will be recursively
# searched for all files, and applied with -f

: ${1?"Missing input directory (chart of charts)"} \
  ${2?"Missing deployment directory"} \
  ${3?"Missing output directory"} \
  ${4-""}

_idir=$1          # directory charts will be build from (chart-of-charts)
_deployments=$2   # directory deployment files will be retrieved from
_odir=$3          # output directory
_postfix=$4       # (optional) postfix on output files

[[ ! -d $_idir ]] && echo "idir (arg1) must be a directory!" && exit 1
[[ ! -d $_deployments ]] && echo "deployments (arg2) must be a directory!" && exit 1
mkdir -p $_odir 
!($!) && echo "odir (arg3) must be a valid directory!" && exit 1

_files=$(cd ${_deployments} && find ~+ \( ! -regex '.*/\..*' \) -type f)

helm dependency build
helm dependency update

echo "templating from deployment files"
echo "${_files}"
for f0 in $_files; do
  _0=$(basename $f0 .${f0##*.}) # get file names, minus extension
  _tplfile=${_odir}/${_0}${_postfix}.yaml

  tput setaf 8 ; date
  tput setaf 2 ; echo "templating $_tplfile"

  helm template ${_idir} -f ${f0} > ${_tplfile}
done
