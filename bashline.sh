#!/bin/bash
#
#
# Bashline
# Tiny, fast Powerline-like Bash prompt with max exec time
# https://github.com/superjer/bashline
#
#
# What you get:
#
#   * Color-coded hostnames when you SSH to different machines.
#
#   * Powerline-like path with abbreviations for favorite dirs.
#
#   * Git branch, detached head, merge- or rebase-state (__git_ps1).
#
#   * Color-coded Git working dir indicators:
#       * D - dirty   - blue  - tracked files have modifications
#       * I - index   - green - files have been indexed / added
#       * U - unknown - red   - untracked files present
#
#   * Git status is not allowed to take more than 1 second.
#       * If it takes too long you will see a ? instead of D/I/U.
#
#   * Error code from last ran command ($?).
#
#
# Dependencies (you should already have these):
#
#   256-color term  - needed for this to work at all
#   git             - to enable working dir status indicators
#   __git_ps1       - to see branch name, merge status, etc.
#   timeout         - to enable max exec time feature
#   Bash 4+         - to enable host colors, fav dirs, & Git status colors
#
#
# Powerline Fonts:
#
#   You need to install a font with the special Powerline symbols.
#
#      https://github.com/Lokaltog/powerline-fonts
#
#   Fonts only need to be installed on your client machine. If you are using
#   SSH there is no need to install the fonts on the remote machine.
#
#
# Install and personalize Bashline:
#
#   To install, just source bashline.sh in your .bashrc file.
#
#   Here's an example that also adds host colors and favorite dirs: (Bash 4+ required)
#
#     . /path/to/bashline.sh
#     bashline_hosts[lala]="230 128" # 230 foreground, 128 background
#     bashline_hosts[lois]="201 55"
#     bashline_hosts[clark]="231 160"
#     bashline_hosts[swamp]="148 22"
#     bashline_hosts[xenon]="160 234"
#     bashline_hosts[kristi]="17 214"
#     bashline_hosts[tengen]="231 198"
#     bashline_hosts[creeper]="16 112"
#     bashline_hosts[infocom]="226 211"
#     bashline_hosts[krypton]="99 54"
#     bashline_hosts[macpork]="87 99"
#     bashline_hosts[icecrown]="51 18"
#     bashline_hosts[magellan]="226 202"
#     bashline_hosts[ferdinand]="88 172"
#     bashline_hosts[swingline]="124 228"
#     bashline_hosts[snickerdoodle]="214 25"
#     bashline_favs[/var/www/html/superjer.com]="♥ j"
#     bashline_favs[/var/www/html/mcdiddys.com]="♥ mcd"
#     bashline_favs[/weirdly/long/path/that/makes/the/prompt/sad]="♥ a short name"
#
#  256-color terminal palette in pictures:
#
#     http://blog.yjl.im/2013/02/terminal-256-colors-scripts.html
#
#  You can also set the hostname and user to get shortened to your liking:
#
#     bashline_shorten=5  # shorten to just 5 characters
#
#
# Note:
#
#   Bashline will attempt to degrade gracefully if there are missing
#   dependencies. If you are missing a feature, you probably need to
#   install or upgrade the relevant program.
#

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
    bashline_hosts="16 22"
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
    porc=$($t1s $git status --porcelain | cut -c1-2 | tr ' ' .)
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
    echo -n " "
  fi

  echo -n " $hostshort "
  bashline_colors ${hostcolors#* } 31
  echo -n " "
  bashline_colors 231 31
  echo -n "$meshort "
  bashline_colors 31 240
  echo -n " "

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

      delim=""
    done
  done <<< "$pathfav"

  local colorleft=240

  if [ -n "$branch" ] ; then
    bashline_colors $colorleft 17
    echo -n " "

    if [ -n "$status" ] ; then
      bashline_colors ${diu[$status]} 17
      echo -n " $status"
    else
      bashline_colors 240 17
      echo -n ""
    fi

    echo -n "$branch "
    colorleft=17
  fi

  if [ "$error" -ne 0 ] ; then
    bashline_colors $colorleft 52
    echo -n " "
    bashline_colors 231 52
    echo -n "$error "
    colorleft=52
  fi

  bashline_colors $colorleft
  echo -n " "
  bashline_colors
}

PROMPT_COMMAND='PS1=$(bashline_prompt "$?" "$(__git_ps1)" || "$PS1")'
