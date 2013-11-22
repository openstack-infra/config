:title: Security Gerrit

.. _gerrit:

Security Gerrit
###############

Security Gerrit is a private Gerrit instance we use for reviewing
security patches.  We setup this instance so that we can provide
a set of trusted users access to security patches.

This section describes how security Gerrit is configured.  To understand
security Gerrit you will need to familiarized yourself with the setup
and configuration of our open Gerrit.  This is a subset of the information
found in :doc:`open Gerrit documentation <gerrit>`

Workflow
========
The security review instance of gerrit will have a slightly different workflow
than `the open Gerrit <https://wiki.openstack.org/wiki/GerritJenkinsGit>`_.

The security review workflow:

#. User does git clone from review-security.o.o
#. User does git review patch to review-security.o.o
#. The patch is review-able by member of VMT group, change owner and
   any manually added reviewer.
#. The patch is reviewed and approved on review-security.o.o
#. The patch is copied from review-security.o.o to public review.o.o
     a. git review -d patch from review-security.o.o
     b. git review -r patch to review.o.o [1]_

.. [1] patch set information (votes/comments/etc..) does not not get
   copied to review.o.o


At a Glance
===========

:Hosts:
  * http://review-security.openstack.org
:Puppet:
  * :file:`modules/openstack_project/manifests/review_security.pp`
:Configuration:
  * :file:`modules/openstack_project/templates/review.projects.yaml.erb`
:Projects:
  * http://code.google.com/p/gerrit/
:Bugs:
  * http://bugs.launchpad.net/openstack-ci
  * http://code.google.com/p/gerrit/issues/list
:Resources:
  * `Gerrit Documentation <https://review.openstack.org/Documentation/index.html>`_

.. _acl:

Access Controls
===============

High level goals:

#. Security Users can read all projects.
#. Security Users can create changes.
#. Security Users can perform informational code review (+/-1)
   on any project.
#. Vulnerability Managers can perform full code review.
   (blocking or approving: +/- 2), and submit changes to be merged.
#. Vulnerability Managers can tag releases (push annotated tags).
#. Vulnerability Managers can add and remove users from Security Users group.

The `All-Projects.config` should look like::

  [project]
      description = Rights inherited by all other projects
      state = active
  [access "refs/*"]
      read = group Vulnerability Managers
      pushTag = group Project Bootstrappers
      pushTag = group Vulnerability Managers
      forgeAuthor = group Registered Users
      forgeCommitter = group Project Bootstrappers
      push = +force group Project Bootstrappers
      create = group Project Bootstrappers
      create = group Vulnerability Managers
      pushMerge = group Project Bootstrappers
  [access "refs/heads/*"]
      label-Code-Review = -2..+2 group Project Bootstrappers
      label-Code-Review = -1..+1 group Registered Users
      label-Verified = -2..+2 group Project Bootstrappers
      submit = group Project Bootstrappers
      label-Approved = +0..+1 group Project Bootstrappers
  [access "refs/meta/config"]
      read = group Project Owners
  [access "refs/for/refs/*"]
      push = group Registered Users
  [access "refs/heads/milestone-proposed"]
      exclusiveGroupPermissions = label-Approved label-Code-Review
      label-Code-Review = -2..+2 group Project Bootstrappers
      label-Code-Review = -2..+2 group Vulnerability Managers
      label-Code-Review = -1..+1 group Registered Users
      owner = group Release Managers
      label-Approved = +0..+1 group Project Bootstrappers
      label-Approved = +0..+1 group Vulnerability Managers
  [access "refs/heads/stable/*"]
      forgeAuthor = group Vulnerability Managers
      forgeCommitter = group Vulnerability Managers
      exclusiveGroupPermissions = label-Approved label-Code-Review
      label-Code-Review = -2..+2 group Project Bootstrappers
      label-Code-Review = -2..+2 group Vulnerability Managers
      label-Code-Review = -1..+1 group Registered Users
      label-Approved = +0..+1 group Project Bootstrappers
      label-Approved = +0..+1 group Vulnerability Managers
  [capability]
      administrateServer = group Administrators
      priority = batch group Non-Interactive Users
      createProject = group Project Bootstrappers


Each project should contain it's own security users group to
allow the VMT group to assign users to review security patches.

An example of Nova's `project.config` should look like::

  [access "refs/*"]
      read = group nova-security-users
  [access "refs/heads/*"]
      label-Code-Review = -2..+2 group nova-security-users
  [access "refs/heads/milestone-proposed"]
      label-Code-Review = -2..+2 group nova-security-users
  [access "refs/heads/stable/*"]
      label-Code-Review = -2..+2 group nova-security-users

