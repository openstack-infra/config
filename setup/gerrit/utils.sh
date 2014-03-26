#!/usr/bin/env bash

# reset_project contrail-controller

function set_date {
  date=`ssh anantha@fedora-build03 date`
  hwclock --set --date="$date" && hwclock -s
  date --set "$date"
}

function puppet_install {
  apt-get -y install git python-pip
  pip install -U pip

  # Setup time
  set_date

  # Run puppet agent
  puppet agent --test
}

function reset_project() {
  PROJECT=$1
  rm -rf ~gerrit2/review_site/git/stackforge/$PROJECT.git /var/lib/jeepyb/stackforge/$PROJECT
  service gerrit restart
  manage-projects -dv
}

function ls_projects() {
    ssh -qp 29418 review.opencontrail.org gerrit ls-projects
}

function ls_groups() {
    ssh -qp 29418 review.opencontrail.org gerrit ls-groups
}
