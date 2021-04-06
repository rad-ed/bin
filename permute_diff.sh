#!/bin/bash
#
# Finds all non-hidden files in directory and then performs a permutation on
# discovered files, applying diff to each. Writes to output file. Optional
# append 
#


# check args
: ${1:?"Missing input directory"} ${2:?"Missing output directory"} ${3:-""}

_idir=$1  # directory which will be searched for files in all subdirs
_odir=$2  # directory which will be created & diffiles placed
_append=$3  # (optional) append to filename for comparison

[[ ! -d $_idir ]] && echo "indir (arg1) must be a directory!" && exit 1

mkdir -p $_odir 
($! = 0) && echo "indir (arg1) must be a valid directory!" && exit 1

# get absolute paths of all non-hidden files
_files=$(cd ${_idir} && find ~+ \( ! -regex '.*/\..*' \) -type f)

# permutate & diff
echo "Permuting diffs for files"
echo "${_files}"
echo "and writing to ${_odir}"
for f0 in $_files; do
  for f1 in $_files; do

    # do not compare files with themselves
    if [[ "$f0" != "$f1" ]]; then

      # get file names, minus extension
      _0=$(basename $f0 .${f0##*.})
      _1=$(basename $f1 .${f1##*.})

      # destination filename will be outdir/file0-file1.diff
      _diffile=${_odir}/${_0}-${_1}${_append}.diff

      date
      tput setaf 1 ; echo "writing $_diffile"

      echo "$(diff $f0 $f1)" > $_diffile
    fi
  done
done