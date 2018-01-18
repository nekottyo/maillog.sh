#!/bin/bash
# vi: tabstop=2 autoindent expandtab shiftwidth=2

LOGPATH=${1:-./maillog}

usage() {
  cat << EOF
Usage: ${0} maillog

Option:
  -h  this help

EOF
}

while getopts "h" opts; do
  case $opts in
    \?|h)
      usage
      exit 1
      ;;
    *)
  esac
done

shift $(( $OPTIND - 1 ))



awk '/dsn=2.0.0/{print $6}' ${LOGPATH} \
  | sort \
  | uniq \
  | while read qid; do
      grep -F "${qid}" "${LOGPATH}" \
        | xargs \
        | grep " from=<" \
        | perl -pe 's/^(\w+\s+\d+\s+\d{2}:\d{2}:\d{2})\s.+?\s(.{14}):\s*from=(<.*?>),\s.+?\smsgid=<*(.+?)>*,\s.+?\sto=(<.*?>),\s.+\s$/$1, $2, $3, $5, $4\n/g; s/>,</></g'
done
