:title: OpenAFS

.. _openafs:

OpenAFS
#######

The Andrew Filesystem (or AFS) is a global distributed filesystem.
With a single mountpoint, clients can access any site on the Internet
which is running AFS as if it were a local filesystem.

OpenAFS is an open source implementation of the AFS services and
utilities.

A collection of AFS servers and volumes that are collectively
administered within a site is called a ``cell``.  The OpenStack
project runs the ``openstack.org`` AFS cell, accessible at
``/afs/openstack.org/``.

At a Glance
===========

:Hosts:
  * afsdb01.openstack.org (a vldb and pts server in DFW)
  * afsdb02.openstack.org (a vldb and pts server in ORD)
  * afs01.dfw.openstack.org (a fileserver in DFW)
  * afs02.dfw.openstack.org (a second fileserver in DFW)
  * afs01.ord.openstack.org (a fileserver in ORD)
:Puppet:
  * https://git.openstack.org/cgit/openstack-infra/puppet-openafs/tree/
  * :file:`modules/openstack_project/manifests/afsdb.pp`
  * :file:`modules/openstack_project/manifests/afsfs.pp`
:Projects:
  * http://openafs.org/
:Bugs:
  * http://bugs.launchpad.net/openstack-ci
  * http://rt.central.org/rt/Search/Results.html?Order=ASC&DefaultQueue=10&Query=Queue%20%3D%20%27openafs-bugs%27%20AND%20%28Status%20%3D%20%27open%27%20OR%20Status%20%3D%20%27new%27%29&Rows=50&OrderBy=id&Page=1&Format=&user=guest&pass=guest
:Resources:
  * `OpenAFS Documentation <http://docs.openafs.org/index.html>`_

OpenStack Cell
--------------

AFS may be one of the most thoroughly documented systems in the world.
There is plenty of very good information about how AFS works and the
commands to use it.  This document will only cover the mininmum needed
to understand our deployment of it.

OpenStack runs an AFS cell called ``openstack.org``.  There are three
important services provided by a cell: the volume location database
(VLDB), the protection database (PTS), and the file server (FS).  The
volume location service answers queries from clients about which
fileservers should be contacted to access particular volumes, while
the protection service provides information about users and groups.

Our implementation follows the common recommendation to colocate the
VLDB and PTS servers, and so they both run on our afsdb* servers.
These servers all have the same information and communicate with each
other to keep in sync and automatically provide high-availability
service.  For that reason, one of our DB servers is in the DFW region,
and the other in ORD.

Fileservers contain volumes, each of which is a portion of the file
space provided by that cell.  A volume appears as at least one
directory, but may contain directories within the volume.  Volumes are
mounted within other volumes to construct the filesystem hierarchy of
the cell.

OpenStack has two fileservers in DFW and one in ORD.  They do not
automatically contain copies of the same data.  A read-write volume in
AFS can only exist on exactly one fileserver, and if that fileserver
is out of service, the volumes it serves are not available.  However,
volumes may have read-write copies which are stored on other
fileservers.  If a client requests a read-only volume, as long as one
site with a read-only volume is online, it will be available.

Client Configuration
--------------------
.. _afs_client:

To use OpenAFS on a Debian or Ubuntu machine::

  sudo apt-get install openafs-client openafs-krb5 krb5-user

Debconf will ask you for a default realm, cell and cache size.
Answer::

  Default Kerberos version 5 realm: OPENSTACK.ORG
  AFS cell this workstation belongs to: openstack.org
  Size of AFS cache in kB: 500000

The default cache size in debconf is 50000 (50MB) which is not very
large.  We recommend setting it to 500000 (500MB -- add a zero to the
default debconf value), or whatever is appropriate for your system.

The OpenAFS client is not started by default, so you will need to
run::

  sudo service openafs-client start

When it's done, you should be able to ``cd /afs/openstack.org``.

Most of what is in our AFS cell does not require authentication.
However, if you have a principal in kerberos, you can get an
authentication token for use with AFS with::

  kinit
  aklog

Administration
--------------

The following information is relevant to AFS administrators.

All of these commands have excellent manpages which can be accessed
with commands like ``man vos`` or ``man vos create``.  They also
provide short help messages when run like ``vos -help`` or ``vos
create -help``.

For all administrative commands, you may either run them from any AFS
client machine while authenticated as an AFS admin, or locally without
authentication on an AFS server machine by appending the `-localauth`
flag to the end of the command.

Adding a User
~~~~~~~~~~~~~
First, add a kerberos principal as described in :ref:`addprinc`.  Have the
username and UID from puppet ready.

Then add the user to the protection database with::

  pts createuser $USERNAME -id UID

Admin UIDs start at 1 and increment.  If you are adding a new admin
user, you must run ``pts listentries``, find the highest UID for an
admin user, increment it by one and use that as the UID.  The username
for an admin user should be in the form ``username.admin``.

.. note::
  Any '/' characters in a kerberos principal become '.' characters in
  AFS.

Adding a Superuser
~~~~~~~~~~~~~~~~~~
Run the following commands to add an existing principal to AFS as a
superuser::

  bos adduser -server afsdb01.openstack.org -user $USERNAME.admin
  bos adduser -server afsdb02.openstack.org -user $USERNAME.admin
  bos adduser -server afs01.dfw.openstack.org -user $USERNAME.admin
  bos adduser -server afs02.dfw.openstack.org -user $USERNAME.admin
  bos adduser -server afs01.ord.openstack.org -user $USERNAME.admin
  pts adduser -user $USERNAME.admin -group system:administrators

Deleting Files
~~~~~~~~~~~~~~

.. note::
  This is a basic example of write operations for AFS-hosted
  content, so applies more generally to manually adding or changing
  files as well. As we semi-regularly get requests to delete
  subtrees of documentation, this serves as a good demonstration.

First, as a prerequisite, make sure you've followed the `Client
Configuration`_ and `Adding a Superuser`_ steps for yourself and
that you know the password for your ``$USERNAME/admin`` kerberos
principal. Safely authenticate your superuser's principal in a new
PAG as follows::

  pagsh -c /bin/bash
  export KRB5CCNAME=FILE:`mktemp`
  kinit $USERNAME/admin
  aklog

If this is a potentially destructive change (perhaps you're worried
you might mistype a deletion and remove more content than you
intended) you can first create a copy-on-write backup snapshot like
so::

  vos backup docs

When deleting files, note that you should use the read-write
``/afs/.openstack.org`` path rather than the read-only
``/afs/openstack.org`` path, but normal Unix file manipulation
commands work as expected (do _not_ use ``sudo`` for this)::

  rm -rf /afs/.openstack.org/docs/project-install-guide/baremetal/draft

If you don't want to have to wait for a volume release to happen (so
that your changes to the read-write filesystem are reflected
immediately in the read-only filesystem), you can release it now
too::

  vos release docs

Now you can clean up your session, destroy your ticket and exit the
temporary PAG thusly::

  unlog
  kdestroy
  exit

Creating a Volume
~~~~~~~~~~~~~~~~~

Select a fileserver for the read-write copy of the volume according to
which region you wish to locate it after ensuring it has sufficient
free space.  Then run::

  vos create $FILESERVER a $VOLUMENAME

The `a` in the preceding command tells it to place the volume on
partition `vicepa`.  Our fileservers only have one partition and therefore
this is a constant.

Be sure to mount the read-write volume in AFS with::

  fs mkmount /afs/.openstack.org/path/to/mountpoint $VOLUMENAME

You may want to create read-only sites for the volume with ``vos
addsite`` and then ``vos release``.

You should set the volume quota with ``fs setquota``.

Adding a Fileserver
~~~~~~~~~~~~~~~~~~~
Put the machine's public IP on a single line in
/var/lib/openafs/local/NetInfo (TODO: puppet this).

Copy ``/etc/openafs/server/*`` from an existing fileserver.

Create an LVM volume named ``vicepa`` from cinder volumes.  See
:ref:`cinder` for details on volume management.  Then run::

  mkdir /vicepa
  echo "/dev/main/vicepa  /vicepa ext4  errors=remount-ro,barrier=0  0  2" >>/etc/fstab
  mount -a

Finally, create the fileserver with::

  bos create -server NEWSERVER -instance dafs -type dafs \
    -cmd "/usr/lib/openafs/dafileserver -L -p 242 -busyat 600 -rxpck 700 \
      -s 1200 -l 1200 -cb 1500000 -b 240 -vc 1200 \
      -udpsize 131071 -sendsize 131071" \
    -cmd /usr/lib/openafs/davolserver \
    -cmd /usr/lib/openafs/salvageserver \
    -cmd /usr/lib/openafs/dasalvager

It is worth evaluating these settings periodically

* ``-L`` selects the large size, which ups a number of defaults
* ``-p`` defines the worker threads for processing incoming calls.
  Since they block until there is work to do, we should leave this at
  around the maximum (which may increase across versions; see
  documentation)
* ``-udpsize`` and ``-sendsize`` should be increased above their default
* ``-cb`` defines the callbacks.  For our use case, with a single
  mirror writer, this should be around the number of files the client
  is configured to cache (``-dcache``) multiplied by the number of
  clients.

Updating Settings
~~~~~~~~~~~~~~~~~

If you wish to update the settings for an existing server, you can
stop and remove the existing ``bnode`` (the collection of processes
the overseeer is monitoring, created via ``bos create`` above) and
recreate it.

For example ::

  bos stop -server afs01.dfw.openstack.org \
           -instance dafs \
           -wait

Then remove the server with ::

  bos delete -server afs01.dfw.openstack.org \
             -instance dafs

Finally run the ``bos create`` command above with any modified
parameters to restart the server.

Mirrors
~~~~~~~

We host mirrors in AFS so that we store only one copy of the data, but
mirror servers local to each cloud region in which we operate serve
that data to nearby hosts from their local cache.

All of our mirrors are housed under ``/afs/openstack.org/mirror``.
Each mirror is on its own volume, and each with a read-only replica.
This allows mirrors to be updated and then the read-only replicas
atomically updated.  Because mirrors are typically very large and
replication across regions is slow, we place both copies of mirror
data on two fileservers in the same region.  This allows us to perform
maintenance on fileservers hosting mirror data as well deal with
outages related to a single server, but does not protect the mirror
system from a region-wide outage.

In order to establish a new mirror, do the following:

* The following commands need to be run authenticated on a host with
  kerberos and AFS setup (see `afs_client`_; admins can run the
  commands on ``mirror-update.openstack.org``).  Firstly ``kinit`` and
  ``aklog`` to get tokens.

* Create the mirror volume.  See `Creating a Volume`_ for details.
  The volume should be named ``mirror.foo``, where `foo` is
  descriptive of the contents of the mirror.  Example::

    vos create afs01.dfw.openstack.org a mirror.foo

* Create read-only replicas of the volume.  One replica should be
  located on the same fileserver (it will take little to no additional
  space), and at least one other replica on a different fileserver.
  Example::

    vos addsite afs01.dfw.openstack.org a mirror.foo
    vos addsite afs02.dfw.openstack.org a mirror.foo

* Release the read-only replicas::

    vos release mirror.foo

  See the status of all volumes with::

    vos listvldb

When traversing from a read-only volume to another volume across a
mountpoint, AFS will first attempt to use a read-only replica of the
destination volume if one exists.  In order to naturally cause clients
to prefer our read-only paths for mirrors, the entire path up to that
point is composed of read-only volumes::

  /afs             [root.afs]
    /openstack.org [root.cell]
      /mirror      [mirror]
        /bar       [mirror.bar]

In order to mount the ``mirror.foo`` volume under ``mirror`` we need
to modify the read-write version of the ``mirror`` volume.  To make
this easy, the read-write version of the cell root is mounted at
``/afs/.openstack.org``.  Folllowing the same logic from earlier,
traversing to paths below that mount point will generally prefer
read-write volumes.

* Mount the volume into afs using the read-write path::

    fs mkmount /afs/.openstack.org/mirror/foo mirror.foo

* Release the ``mirror`` volume so that the (currently empty) foo
  mirror itself appears in directory listings under
  ``/afs/openstack.org/mirror``::

    vos release mirror

* Create a principal for the mirror update process.  See
  :ref:`addprinc` for details.  The principal should be called
  ``service/foo-mirror``.  Example::

    kadmin: addprinc -randkey service/foo-mirror@OPENSTACK.ORG
    kadmin: ktadd -k /path/to/foo.keytab service/foo-mirror@OPENSTACK.ORG

* Add the service principal's keytab to hiera.  Copy the binary key to
  ``puppetmaster.openstack.org`` and then use ``hieraedit`` to update
  the files

  .. code-block:: console

    root@puppetmaster:~# /opt/system-config/production/tools/hieraedit.py \
      --yaml /etc/puppet/hieradata/production/fqdn/mirror-update.openstack.org.yaml \
      -f /path/to/foo.keytab KEYNAME

  (don't forget to ``git commit`` and save the change; you can remove
  the copies of the binary key too).  The key will be base64 encoded
  in the heira database.  If you need to examine it for some reason
  you can use ``base64``::

    cat /path/to/foo.keytab | base64

* Add the new key to ``mirror-update.openstack.org`` in
  ``manifests/site.pp`` for the mirror scripts to use during update.

* Create an AFS user for the service principal::

    pts createuser service.foo-mirror

Because mirrors usually have a large number of directories, it is best
to avoid frequent ACL changes.  To this end, we grant access to the
mirror directories to a group where we can easily modify group
membership if our needs change.

* Create a group to contain the service principal, and add the
  principal::

    pts creategroup foo-mirror
    pts adduser service.foo-mirror foo-mirror

  View users, groups, and their membership with::

    pts listentries
    pts listentries -group
    pts membership foo-mirror

* Grant the group access to the mirror volume::

    fs setacl /afs/.openstack.org/mirror/foo foo-mirror write

* Grant anonymous users read access::

    fs setacl /afs/.openstack.org/mirror/foo system:anyuser read

* Set the quota on the volume (e.g., 100GB)::

    fs setquota /afs/.openstack.org/mirror/foo 100000000

Because the initial replication may take more time than we allocate in
our mirror update cron jobs, manually perform the first mirror update:

* In screen, obtain the lock on ``mirror-update.openstack.org``::

    flock -n /var/run/foo-mirror/mirror.lock bash

  Leave that running while you perform the rest of the steps.

* Also in screen on ``mirror-update``, run the initial mirror sync.
  If using one of the mirror update scripts (from ``/usr/local/bin``)
  be aware that they generally run the update process under
  ``timeout`` with shorter periods than may be required for the
  initial full sync.  e.g. for ``reprepro`` mirrors

    NO_TIMEOUT=1 /usr/local/bin/reprepro-mirror-update /etc/reprepro/ubuntu mirror.ubuntu

* Log into ``afs01.dfw.openstack.org`` and run ``screen``.  Within
  that session, periodically during the sync, and once again after it
  is complete, run::

    vos release mirror.foo -localauth

  It is important to do this from an AFS server using ``-localauth``
  rather than your own credentials and inside of screen because if
  ``vos release`` is interrupted, it will require some manual cleanup
  (data will not be corrupted, but clients will not see the new volume
  until it is successfully released).  Additionally, ``vos release`` has
  a bug where it will not use renewed tokens and so token expiration
  during a vos release may cause a similar problem.

* Once the initial sync and and ``vos release`` are complete, release
  the lock file on mirror-update.

Removing a mirror
~~~~~~~~~~~~~~~~~

If you need to remove a mirror, you can do the following:

* Unmount the volume from the R/W location::

    fs rmmount /afs/.openstack.org/mirror/foo

* Release the R/O mirror volume to reflect the changes::

    vos release mirror

* Check what servers the volumes are on with ``vos listvldb``::

    VLDB entries for all servers
    ...

    mirror.foo
        RWrite: 536870934     ROnly: 536870935
        number of sites -> 3
           server afs01.dfw.openstack.org partition /vicepa RW Site
           server afs01.dfw.openstack.org partition /vicepa RO Site
           server afs01.ord.openstack.org partition /vicepa RO Site
     ...

* Remove the R/O replicas (you can also see these with ``vos
  listvol -server afs0[1|2].dfw.openstack.org``)::

    vos remove -server afs01.dfw.openstack.org -partition a -id mirror.foo.readonly
    vos remove -server afs02.dfw.openstack.org -partition a -id mirror.foo.readonly

* Remove the R/W volume::

    vos remove -server afs02.dfw.openstack.org -partition a -id mirror.foo

Reverse Proxy Cache
^^^^^^^^^^^^^^^^^^^

* `modules/openstack_project/templates/mirror.vhost.erb
  <https://git.openstack.org/cgit/openstack-infra/system-config/tree/modules/openstack_project/templates/mirror.vhost.erb>`__

Each of the region-local mirror hosts exposes a limited reverse HTTP
proxy on port 8080.  These proxies run within the same Apache setup as
used to expose AFS mirror contents.  `mod_cache
<https://httpd.apache.org/docs/2.4/mod/mod_proxy.html>`__ is used to
expose a white-listed set of resources (currently just RDO).

Currently they will cache data for up to 24 hours (Apache default)
with pruning performed by ``htcacheclean`` once an hour to keep the
cache size at or under 2GB of disk space.

The reverse proxy is provided because there are some hosted resources
that are not currently able to be practically mirrored.  Examples of
this include RDO (rsync from RDO is slow and they update frequently)
and docker images (which require specialized software to run a docker
registry and then sorting out how to run that on a shared filesystem).

Apache was chosen because we already had configuration management in
place for Apache on these hosts.  This avoids management overheads of
a completely new service deployment such as Squid or a caching docker
registry daemon.

No Outage Server Maintenance
----------------------------

afsdb0X.openstack.org
~~~~~~~~~~~~~~~~~~~~~

We have redundant AFS DB servers. You can take one down without causing
a service outage as long as the other remains up. To do this safely::

  root@afsdb01:~# bos shutdown afsdb01.openstack.org -wait -localauth
  root@afsdb01:~# bos status afsdb01.openstack.org -localauth
  Instance ptserver, temporarily disabled, currently shutdown.
  Instance vlserver, temporarily disabled, currently shutdown.

Then perform your maintenance on afsdb01. When done a reboot will
automatically restart the bos service or you can manually restart
the openafs-fileserver service::

  root@afsdb01:~# service openafs-fileserver start

Finally check that the service is back up and running::

  root@afsdb01:~# bos status afsdb01.openstack.org -localauth
  Instance ptserver, currently running normally.
  Instance vlserver, currently running normally.

Now you can repeat the process against afsdb02.

afs0X.openstack.org
~~~~~~~~~~~~~~~~~~~

Taking down the actual fileservers is slightly more complicated
but works similarly. Basically what we need to do is make sure that
either no one needs the RW volumes hosted by a fileserver before
taking it down or move the RW volume to another fileserver.

To ensure nothing needs the RW volumes you can hold the various
file locks on hosts that publish to AFS and/or remove cron entries
that perform vos releases or volume writes.

If instead you need to move the RW volume first step is checking
where the volumes live::

  root@afsdb01:~# vos listvldb -localauth
  VLDB entries for all servers

  mirror
      RWrite: 536870934     ROnly: 536870935
      number of sites -> 3
         server afs01.dfw.openstack.org partition /vicepa RW Site
         server afs01.dfw.openstack.org partition /vicepa RO Site
         server afs01.ord.openstack.org partition /vicepa RO Site

We see that if we want to allow write to the mirror volume and take
down afs01.dfw.openstack.org we will have to move the volume to one
of the other servers::

  root@afsdb01:~# screen # use screen as this may take quite some time.
  root@afsdb01:~# vos move -id mirror -toserver afs01.ord.openstack.org -topartition vicepa -fromserver afs01.dfw.openstack.org -frompartition vicepa -localauth

When that is done (use listvldb command above to check) it is now safe
to take down afs01.dfw.openstack.org while having writers to the mirror
volume. We use the same process as for the db server::

  root@afsdb01:~# bos shutdown afs01.dfw.openstack.org -localauth
  root@afsdb01:~# bos status afsdb01.dfw.openstack.org -localauth
  Auxiliary status is: file server shut down.

Perform maintenance, then restart as above and check the status again::

  root@afsdb01:~# bos status afsdb01.dfw.openstack.org -localauth
  Auxiliary status is: file server running.

DNS Entries
-----------

AFS uses the following DNS entries::

  _afs3-prserver._udp.openstack.org. 300 IN SRV 10 10 7002 afsdb01.openstack.org.
  _afs3-prserver._udp.openstack.org. 300 IN SRV 10 10 7002 afsdb02.openstack.org.
  _afs3-vlserver._udp.openstack.org. 300 IN SRV 10 10 7003 afsdb01.openstack.org.
  _afs3-vlserver._udp.openstack.org. 300 IN SRV 10 10 7003 afsdb02.openstack.org.

Be sure to update them if volume location and PTS servers change. Also note
that only A (IPv4 address) records are used in the SRV data. Since OpenAFS
lacks support for IPv6, avoid entering corresponding AAAA (IPv6 address)
records for these so that it won't cause fallback delays for other
v6-supporting AFS client implementations.
