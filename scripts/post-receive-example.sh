#!/bin/bash

source "$HOME/.bash_profile"

info () {
  printf "\r\033[2K  \033[1m\033[34m$1\033[0m"
  echo ""
}

success () {
  printf "\r\033[2K  \033[1m\033[32m$1\033[0m"
  echo ""
}

while read oldrev newrev ref
do
  branch=`echo $ref | cut -d/ -f3`

  live=samking.co
  staging=staging.$live
  dev=dev.$live

  if [ "master" == "$branch" ]
  then
    info 'Pushing & Checking Out *live'
    git --work-tree=/srv/www/$live/public checkout -f $branch
    success 'Changes pushed live'
    info "Now it's time to grunt!"
    cd /srv/www/$live/public && grunt dist
    success 'Success!'
    info 'Now visit '$live
  elif [ "staging" == "$branch" ]
  then
    info 'Pushing & Checking Out *staging'
    git --work-tree=/srv/www/$staging/public checkout -f $branch
    success 'Changes pushed to staging'
    info "Now it's time to grunt!"
    cd /srv/www/$staging/public && grunt
    success 'Success!'
    info 'Now visit '$staging
  else
    info 'Pushing & Checking Out *'$branch
    git --work-tree=/srv/www/$dev/public checkout -f $branch
    success 'Changes pushed to '$branch
    info "Now it's time to grunt!"
    cd /srv/www/$dev/public && grunt
    success 'Success!'
    info 'Now visit '$dev
  fi

done
