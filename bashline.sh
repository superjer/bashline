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
# Install Bashline:
#
#   Add this to your .bashrc (use full path to bashline.sh):
#
#     PROMPT_COMMAND='PS1=$(bashline.sh "$?" "$(__git_ps1)")'
#
#
# Personalize:
#
#   Customize your hosts colors and fav dirs below. Bash 4+ only.
#
#
# Note:
#
#   Bashline will attempt to degrade gracefully if there are missing
#   dependencies. If you are missing a feature, you probably need to
#   install or upgrade the relevant program.
#

error=$1
branch=$2

# length to shorten username and hostname to
shorten=2

if [ ${BASH_VERSINFO[0]} -ge 4 ] ; then
  declare -A hosts # customize these:
  hosts[default]="16 221"
  hosts[lala]="230 128"
  hosts[lois]="201 55"
  hosts[clark]="231 160"
  hosts[swamp]="148 22"
  hosts[xenon]="160 234"
  hosts[kristi]="17 214"
  hosts[tengen]="231 198"
  hosts[creeper]="16 112"
  hosts[infocom]="226 211"
  hosts[krypton]="99 54"
  hosts[macpork]="87 99"
  hosts[icecrown]="51 18"
  hosts[magellan]="226 202"
  hosts[ferdinand]="88 172"
  hosts[swingline]="124 228"
  hosts[snickerdoodle]="214 25"

  declare -A favs # customize these:
  favs[$HOME]="~"
  favs[/var/www/html/superjer.com]="♥ sj"
  favs[/var/www/html/mcdiddys.com]="♥ mcd"
  favs[/weirdly/long/path/that/makes/the/prompt/sad]="♥ a short name"

  declare -A diu
  diu[D]=27
  diu[I]=46
  diu[U]=160
  diu[DI]=51
  diu[DU]=165
  diu[IU]=226
  diu[DIU]=231
  diu['?']=196
else
  hosts="16 22"
  favs=""
  diu=27
fi

t1s=""
which timeout >/dev/null 2>&1 && t1s="timeout 1s"

git=":"
which git >/dev/null 2>&1 && git=git

function fav_conv {
  for x in "${!favs[@]}" ; do
    if [[ $1 == $x* ]] ; then
      echo ${favs["$x"]}${1:${#x}}
      return
    fi
  done

  echo __ROOT__$1
}

function join { local IFS="$1"; shift; echo -n "$*"; }

function colors {
  if [ $# -lt 1 ] ; then
    echo -n "\[[0m\]"
  elif [ $# -lt 2 ] ; then
    echo -n "\[[0;38;5;$1;49;22m\]"
  else
    echo -n "\[[0;38;5;$1;48;5;$2;22m\]"
  fi
}

function mkline {
  local hostname=${HOSTNAME%%.*}
  local hostshort=${hostname:0:$shorten}
  local meshort=${USER:0:$shorten}
  local path=$(fav_conv $(pwd))
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

  if [ -n "${hosts[$hostname]}" ] ; then
    hostcolors=${hosts[$hostname]}
  else
    hostcolors=${hosts[default]}
  fi

  colors $hostcolors

  if [ -n "$SSH_CLIENT" ] ; then
    echo -n " "
  fi

  echo -n " $hostshort "
  colors ${hostcolors#* } 31
  echo -n " "
  colors 231 31
  echo -n "$meshort "
  colors 31 240
  echo -n " "

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
        colors 236 240
        echo -n $delim
      fi

      colors 252 240
      echo -n "$x "

      delim=" "
    done
  done <<< "$path"

  local colorleft=240

  if [ -n "$branch" ] ; then
    colors $colorleft 17
    echo -n " "

    if [ -n "$status" ] ; then
      colors ${diu[$status]} 17
      echo -n " $status"
    else
      colors 238 17
      echo -n ""
    fi

    echo -n "$branch "
    colorleft=17
  fi

  if [ "$error" -ne 0 ] ; then
    colors $colorleft 52
    echo -n " "
    colors 231 52
    echo -n "$error "
    colorleft=52
  fi

  colors $colorleft
  echo -n " "
  colors
}

mkline
