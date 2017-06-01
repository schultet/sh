#!/bin/bash

# gitget.sh lets you `cd` between github repositories using the `gg` (gitget)
# command. If no local copy of the repository exists, gg will clone it first.
# All repositories obtained this way are organized in a uniform workspace
# (rooted at $GG_HOME).

# Command to clone a repo
GG_CLONE=(git clone)

# All repositories are located in $GG_HOME.
GG_HOME=${GG_HOME:-$HOME/src}

# Root directories for the repositories of the git domains used
GG_ROOT=($GG_HOME/github.com $GG_HOME/gkigit.informatik.uni-freiburg.de)

# URL prefixes for each of the used git domains (ssh vs https)
GG_URL_PREFIX=(git@github.com: gkigit@gkigit.informatik.uni-freiburg.de:)
#GG_URL_PREFIX=${GG_URL_PREFIX:-"https://github.com/"}


# gg changes directory to the specified git-repository trying to clone it if it
# doesn't exist.
gg() {
  if [ "$1" = "-h" ] || [ "$#" -ne 2 ]; then
    echo "Usage: gg [user] [project]"
    return
  fi

  for d in ${GG_ROOT[@]}; do
    proj_path=$d/$1/$2
    if [ -d $proj_path ]; then cd $proj_path; return; fi
  done

  i=0
  for d in ${GG_ROOT[@]}; do
    usr_path=$d/$1
    proj_path=$d/$1/$2

    # If project path does not exist, attempt to clone the repository
    if ! [ -d $proj_path ]; then
      cmd=(${GG_CLONE[@]} "${GG_URL_PREFIX[i]}$1/$2.git" $proj_path)
      eval ${cmd[@]}

      # If GG_CLONE returns an error, remove project directory if it exists and 
      # remove the user directory if its empty
      if [ "$?" -ne 0 ]; then 
          if [ -d $proj_path ]; then rm -d $proj_path; fi
          if ! [ "$(ls -A $user_path)" ]; then rm -d $user_path; fi
      fi

      # If path exists, cd into it and break loop
      if [ -d $proj_path ]; then cd $proj_path; break; fi
    fi

    let i=${i}+1
  done
}


# completion for gg command defined above
_gg () {
  local cur
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"

  case $COMP_CWORD in
      1) words=$( ls ${GG_ROOT[@]} ) ;;
      2) 
        words=()
        for d in ${GG_ROOT[@]}; do
          if [ -d "$d"/${COMP_WORDS[COMP_CWORD-1]} ]; then
            words+=$( ls "$d"/${COMP_WORDS[COMP_CWORD-1]} ) 
          fi
        done
        ;;
      *) return 0
  esac
  COMPREPLY=( $(compgen -W "${words}" -- $cur ) )

  return 0
}


# TODO: extend this script to auto-complete using the github api to retrieve all
# (starred) repositories of a user: https://api.github.com/users/<user>/repos
#
# the following only works for github.com repositories:
# USER=schultet; curl --silent \
# "https://api.github.com/users/$USER/repos?per_page=1000" -q | grep -o \
# 'git@[^"]*' | sed -e 's/.*\///g' | sed -e 's/\.git//g'

complete -F _gg gg
