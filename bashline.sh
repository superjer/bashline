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

  declare -A bashline_nicks # customize these:
fi

declare -i bashline_outputlen
declare -i bashline_cols
bashline_curcolor="\[\e[0m\]"

function bashline_colors {
  if [ $# -lt 1 ] ; then
    bashline_curcolor="\[\e[0m\]"
  elif [ $# -lt 2 ] ; then
    bashline_curcolor="\[\e[0;38;5;${1};49m\]"
  else
    bashline_curcolor="\[\e[0;38;5;${1};48;5;${2}m\]"
  fi
  echo -n $bashline_curcolor
}

function bashline_echo {
  bashline_outputlen+=${#1}
  if [ $bashline_outputlen -ge $bashline_cols ] ; then
    echo "\[\e[0m\]"
    echo -n $bashline_curcolor
    bashline_outputlen=${#1}
  fi
  echo -n "$*"
}

function bashline_prompt {
  bashline_outputlen=0
  bashline_cols=999
  hash tput >/dev/null 2>&1 && bashline_cols=$(tput cols)

  local error=$1

  local sym_ssh='╾'
  local sym_sep='❭'
  local sym_section='▶'
  local sym_branch='┣'

  if [ -n "$bashline_powerline_font" ] ; then
    local sym_ssh=''
    local sym_sep=''
    local sym_section=''
    local sym_branch=''
  fi

  local -i hostshorten=$bashline_host_shorten
  local -i usershorten=$bashline_user_shorten
  if [ $hostshorten -lt 1 ] ; then hostshorten=99 ; fi
  if [ $usershorten -lt 1 ] ; then usershorten=99 ; fi

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

  local timestamp=$(echo $(date +%l:%M:%S\ %P))
  local timestamp=$(echo $(date +%k%M%S))

  local hostshort=""
  local hostname=${HOSTNAME%%.*}
  if [ -z "$hostname" ] ; then hostname=$($t1s hostname -s) ; fi
  if [ -z "$hostname" ] ; then hostname='::'                ; fi
  if [ -n "${bashline_nicks[$hostname]}" ] ; then
    hostshort=${bashline_nicks[$hostname]}
  else
    hostshort=${hostname:0:$hostshorten}
  fi

  if test -n "$STY" ; then
    local screenname=${STY}
    screenname=${screenname#*.}
    screenname=${screenname%.*}
    hostshort="$hostshort $screenname"
  fi

  local meshort=""
  local me=$USER
  if [ -z "$me" ] ; then me=$($t1s whoami) ; fi
  if [ -z "$me" ] ; then me=':('           ; fi
  if [ -n "${bashline_nicks[$me]}" ] ; then
    meshort=${bashline_nicks[$me]}
  else
    meshort=${me:0:$usershorten}
  fi

  local path=$PWD
  if [ -z "$path" ] ; then path=$($t1s pwd)    ; fi
  if [ -z "$path" ] ; then path=PATH_NOT_FOUND ; fi
  local pathfav=__ROOT__$path

  declare -i matchlen
  declare -i thismatchlen
  matchlen=0
  for x in "${!bashline_favs[@]}" ; do
    if [[ $path == "$x"* ]] ; then
      thismatchlen=${#x}
      if [ $thismatchlen -gt $matchlen ] ; then
        pathfav=${bashline_favs["$x"]}${path:${#x}}
        matchlen=$thismatchlen
      fi
    fi
  done

  local porc=""
  local pipestatus=""
  local dirty="D"
  local index="I"
  local unknown="U"
  local hostcolors=""
  local branch=""

  local notindotgit=$( $t1s git rev-parse --is-inside-work-tree 2>/dev/null )
  if [ $? -eq 0 ] ; then
    if [ "$notindotgit" == 'true' ] ; then
      git update-index --really-refresh -q &>/dev/null
      branch=$( $t1s git symbolic-ref --quiet --short HEAD 2> /dev/null || \
        $t1s git rev-parse --short HEAD 2> /dev/null || \
        echo '(i dunno what branch)' )
    fi
  fi

  if [ -n "$branch" ] ; then
    $t1s git diff-files --quiet --ignore-submodules --
    pipestatus=${PIPESTATUS[0]}
    case $pipestatus in
      124)
        dirty='?'
        ;;
      0)
        dirty=''
        ;;
    esac
    $t1s git diff --quiet --ignore-submodules --cached
    pipestatus=${PIPESTATUS[0]}
    case $pipestatus in
      124)
        index='?'
        ;;
      0)
        index=''
        ;;
    esac
    untracked=$( $t1s git ls-files --others --exclude-standard )
    if [ $pipestatus -eq 124 ] ; then
      unknown='?'
    elif [ -z "$untracked" ] ; then
      unknown=''
    fi
  fi

  local status=$dirty$index$unknown

  branch=${branch//...}
  branch=${branch//\(\(}
  branch=${branch//\)\)}
  branch=${branch//\(}
  branch=${branch//\)}
  branch=${branch//|/ }

  # update the terminal window title
  echo -ne "\[\033]0;$hostshort ❭ $meshort ❭ $path\007\]"

  if [ -n "${bashline_hosts[$hostname]}" ] ; then
    hostcolors=${bashline_hosts[$hostname]}
  else
    hostcolors=${bashline_hosts[default]}
  fi

  bashline_colors 250 236
  bashline_echo " $timestamp "
  bashline_colors 236 ${hostcolors#* }
  bashline_echo "$sym_section"
  bashline_colors $hostcolors

  if [ -n "$SSH_CLIENT" ] ; then
    bashline_echo " $sym_ssh"
  fi

  bashline_echo " $hostshort "
  bashline_colors ${hostcolors#* } 31
  bashline_echo "$sym_section "
  bashline_colors 231 31
  bashline_echo "$meshort "
  bashline_colors 31 240
  bashline_echo "$sym_section "

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
        bashline_echo "$delim "
      fi

      bashline_colors 252 240
      bashline_echo "$x "

      delim="$sym_sep"
    done
  done <<< "$pathfav"

  local colorleft=240

  if [ -n "$branch" ] ; then
    bashline_colors $colorleft 17
    bashline_echo "$sym_section "

    if [ -n "$status" ] ; then
      bashline_colors ${diu[$status]} 17
      bashline_echo "$sym_branch $status"
    else
      bashline_colors 240 17
      bashline_echo "$sym_branch"
    fi

    bashline_echo " $branch "
    colorleft=17
  fi

  if [ "$error" -ne 0 ] ; then
    bashline_colors $colorleft 52
    bashline_echo "$sym_section "
    bashline_colors 231 52
    bashline_echo "$error "
    colorleft=52
  fi

  bashline_colors $colorleft
  bashline_echo "$sym_section "
  bashline_colors
}

PROMPT_COMMAND='PS1=$(bashline_prompt "$?" || "$PS1")'

# Bash 4.4??
PS0='\e[0;38;5;250;48;5;236m $(date +%H%M%S) \e[0;38;5;236;48;5;52;49m\e[0m\n'
