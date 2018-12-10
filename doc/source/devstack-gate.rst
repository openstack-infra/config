:title: Devstack Gate

.. _devstack-gate:

.. warning::

  devstack-gate is deprecated in favor of Zuul v3 native jobs defined
  in the devstack repo itself. This document describes how devstack-gate
  works as there are still legacy jobs using it.

Devstack Gate
#############

Devstack-gate is a collection of scripts used by the OpenStack CI team
to test every change to core OpenStack projects by deploying OpenStack
via devstack on a cloud server.

At a Glance
===========

:Projects:
  * https://git.openstack.org/cgit/openstack-infra/devstack-gate
:Bugs:
  * https://storyboard.openstack.org/#!/project/712
:Resources:
  * `Devstack-gate README <https://git.openstack.org/cgit/openstack-infra/devstack-gate/tree/README.rst>`_

Overview
========

All changes to core OpenStack projects are "gated" on a set of tests
so that it will not be merged into the main repository unless it
passes all of the configured tests. Most projects require unit tests
with pep8 and several versions of Python. Those tests are all run only
on the project in question. The devstack gate test, however, is an
integration test and ensures that a proposed change still enables
several of the projects to work together. Any proposed change to the
configured set of projects must pass the devstack gate test.

Obviously we test nova, glance, keystone, horizon, neutron and their
clients because they all work closely together to form an OpenStack
system. Changes to devstack itself are also required to pass this test
so that we can be assured that devstack is always able to produce a
system capable of testing the next change to nova. The devstack gate
scripts themselves are included for the same reason.

How It Works
============

The devstack test starts with an essentially bare virtual machine
made available by :ref:`nodepool` and prepares the testing
environment. This is driven by the devstack-gate repository which
holds several scripts that are run by Zuul.

When a proposed change is approved by the core reviewers, Zuul
triggers the devstack gate test itself. This job runs on one of the
previously configured nodes and invokes the devstack-vm-gate-wrap.sh
script which checks out code from all of the involved repositories, and
merges the proposed change.  That script then calls devstack-vm-gate.sh
which installs a devstack configuration file, and invokes devstack. Once
devstack is finished, it runs Tempest, which performs integration testing.
After everything is done, devstack-gate copies and formats all of the logs
for archival.  Zuul then copies these logs to the log archive.

How to Debug a Devstack Gate Failure
====================================

Instructions for debugging a failure can be found in the
`Devstack-gate README <https://git.openstack.org/cgit/openstack-infra/devstack-gate/tree/README.rst>`_

Developer Setup
===============

If you'd like to work on the devstack-gate scripts and test process,
see the `Devstack-gate README <https://git.openstack.org/cgit/openstack-infra/devstack-gate/tree/README.rst>`_
for specific instructions.
