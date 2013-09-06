# Define to install etherpad lite plugins
#
define plugin {
  $plugin_name = $name
  exec { "npm install $plugin_name":
    cwd     => $etherpad_lite::modules_dir,
    path    => $etherpad_lite::path,
    creates => "${etherpad_lite::modules_dir}/${plugin_name}",
    require => Class['etherpad_lite']
  }
}
