# Super simple slave manifest that installs something very
# similar to an OpenStack Jenkins slave but does not need to
# have services managed like firewall, ntp, automatic upgrades,
# and so on.
class opencontrail_project::bare_slave(
  $certname = $::fqdn,
  $install_users = true
) {
  class { 'opencontrail_project::base':
    certname      => $certname,
    install_users => $install_users,
  }

  class { 'jenkins::slave':
    ssh_key => '',
    user    => false
  }
}

# vim:sw=2:ts=2:expandtab:textwidth=79
