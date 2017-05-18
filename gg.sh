#!/bin/bash

# gitget.sh lets you `cd` between github repositories using the `gg` (gitget)
# command. If no local copy of the repository exists, gg will clone it first.
# All repositories obtained this way are organized in a uniform workspace
# (rooted at $GG_HOME).

# All repositories are located in $GG_HOME.
GG_HOME=${GG_HOME:-$HOME/src}

# Domain of repository
GG_DOMAIN=${GG_DOMAIN:-"github.com"}

# Command to clone a repo
GG_CLONE=(git clone)

# URL prefix (ssh vs https)
GG_URL_PREFIX=${GG_URL_PREFIX:-"git@github.com:"}
GG_URL_PREFIX=${GG_URL_PREFIX:-"https://github.com/"}

GG_ROOT=$GG_HOME/$GG_DOMAIN

# gg changes directory to the specified git-repository trying to clone it if it
# doesn't exist.
gg() {
  if [ "$1" = "-h" ] || [ "$#" -ne 2 ]; then
    echo "Usage: gg [user] [project]"
    return
  fi

  usr_path=$GG_ROOT/$1
  proj_path=$GG_ROOT/$1/$2

  # If project path does not exist, attempt to clone the repository
  if ! [ -d $proj_path ]; then
    cmd=(${GG_CLONE[@]} "${GG_URL_PREFIX}$1/$2.git" $proj_path)
    eval ${cmd[@]}

    # If GG_CLONE returns an error, remove project directory if it exists and 
    # remove the user directory if its empty
    if [ "$?" -ne 0 ]; then 
        if [ -d $proj_path ]; then rm -d $proj_path; fi
        if ! [ "$(ls -A $user_path)" ]; then rm -d $user_path; fi
    fi
  fi

  # If path exists, cd into it
  if [ -d $proj_path ]; then cd $proj_path; fi
}


# completion for gg command defined above
_gg () {
  local cur
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"

  case $COMP_CWORD in
      1) words=$( ls $GG_ROOT ) ;;
      2) words=$( ls $GG_ROOT/${COMP_WORDS[COMP_CWORD-1]} ) ;;
      *) return 0
  esac
  COMPREPLY=( $(compgen -W "${words}" -- $cur ) )

  return 0
}

complete -F _gg gg
