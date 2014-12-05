#!/bin/bash
#
# Bashline
# Tiny, fast Powerline-like Bash prompt with max exec time
# https://github.com/superjer/bashline

if [ ${BASH_VERSINFO[0]} -ge 4 ] ; then
  declare -A bashline_hosts # customize these:
  bashline_hosts[default]="16 221"

  declare -A bashline_favs # customize these:
  bashline_favs[$HOME]="~"
fi

function bashline_colors {
  if [ $# -lt 1 ] ; then
    echo -n "\[\e[0m\]"
  elif [ $# -lt 2 ] ; then
    echo -n "\[\e[0;38;5;${1};49m\]"
  else
    echo -n "\[\e[0;38;5;${1};48;5;${2}m\]"
  fi
}

function bashline_prompt {
  local error=$1
  local branch=$2

  local sym_ssh='⚿'
  local sym_sep='❭'
  local sym_section='▶'
  local sym_branch='┣'

  if [ -n "$bashline_powerline_font" ] ; then
    local sym_ssh=''
    local sym_sep=''
    local sym_section=''
    local sym_branch=''
  fi

  local -i shorten=$bashline_shorten
  if [ $shorten -lt 1 ] ; then shorten=2 ; fi

  if [ ${BASH_VERSINFO[0]} -ge 4 ] ; then
    local -A diu
    diu[D]=27
    diu[I]=29
    diu[U]=125
    diu[DI]=38
    diu[DU]=99
    diu[IU]=228
    diu[DIU]=159
    diu['?']=196
  else
    bashline_hosts="16 221"
    bashline_favs=""
    diu=27
  fi

  local t1s=""
  hash timeout >/dev/null 2>&1 && t1s="timeout 1s"

  local git=":"
  hash git >/dev/null 2>&1 && git=git

  local hostname=${HOSTNAME%%.*}
  if [ -z "$hostname" ] ; then hostname=$($t1s hostname -s) ; fi
  if [ -z "$hostname" ] ; then hostname='::'                ; fi
  local hostshort=${hostname:0:$shorten}

  local me=$USER
  if [ -z "$me" ] ; then me=$($t1s whoami) ; fi
  if [ -z "$me" ] ; then me=':('           ; fi
  local meshort=${me:0:$shorten}

  local path=$PWD
  if [ -z "$path" ] ; then path=$($t1s pwd)    ; fi
  if [ -z "$path" ] ; then path=PATH_NOT_FOUND ; fi
  local pathfav=__ROOT__$path

  for x in "${!bashline_favs[@]}" ; do
    if [[ $path == $x* ]] ; then
      pathfav=${bashline_favs["$x"]}${path:${#x}}
      break
    fi
  done

  local porc=""
  local dirty=""
  local index=""
  local unknown=""
  local hostcolors=""

  if [ -n "$branch" ] ; then
    porc=$($t1s $git status --porcelain 2>/dev/null | cut -c1-2 | tr ' ' .)
    if [ ${PIPESTATUS[0]} -eq 124 ] ; then
      dirty='?'
    else
      for x in $porc ; do
        [[ "${x:1:1}" == [MADCRU] ]] && dirty=D
        [[ "${x:0:1}" == [MADCRU] ]] && index=I
        [[ "${x:0:1}" == '?'      ]] && unknown=U
      done
    fi
  fi

  local status=$dirty$index$unknown

  branch=${branch//...}
  branch=${branch//\(\(}
  branch=${branch//\)\)}
  branch=${branch//\(}
  branch=${branch//\)}
  branch=${branch//|/ }

  if [ -n "${bashline_hosts[$hostname]}" ] ; then
    hostcolors=${bashline_hosts[$hostname]}
  else
    hostcolors=${bashline_hosts[default]}
  fi

  bashline_colors $hostcolors

  if [ -n "$SSH_CLIENT" ] ; then
    echo -n " $sym_ssh"
  fi

  echo -n " $hostshort "
  bashline_colors ${hostcolors#* } 31
  echo -n "$sym_section "
  bashline_colors 231 31
  echo -n "$meshort "
  bashline_colors 31 240
  echo -n "$sym_section "

  delim=""

  while IFS=/ read -ra dummy ; do
    for x in "${dummy[@]}" ; do
      if [ -z "$x" ] ; then
        continue
      fi

      if [ "$x" == __ROOT__ ] ; then
        x=/
      fi

      if [ -n "$delim" ] ; then
        bashline_colors 236 240
        echo -n "$delim "
      fi

      bashline_colors 252 240
      echo -n "$x "

      delim="$sym_sep"
    done
  done <<< "$pathfav"

  local colorleft=240

  if [ -n "$branch" ] ; then
    bashline_colors $colorleft 17
    echo -n "$sym_section "

    if [ -n "$status" ] ; then
      bashline_colors ${diu[$status]} 17
      echo -n "$sym_branch $status"
    else
      bashline_colors 240 17
      echo -n "$sym_branch"
    fi

    echo -n "$branch "
    colorleft=17
  fi

  if [ "$error" -ne 0 ] ; then
    bashline_colors $colorleft 52
    echo -n "$sym_section "
    bashline_colors 231 52
    echo -n "$error "
    colorleft=52
  fi

  bashline_colors $colorleft
  echo -n "$sym_section "
  bashline_colors
}

PROMPT_COMMAND='PS1=$(bashline_prompt "$?" "$(if hash __git_ps1 2>/dev/null ; then __git_ps1 ; else echo " ?" ; fi)" || "$PS1")'
