# Nfs_server
#
# Support for NFSv4 kernel server on Linux
#
# The main source of configuration is the `share_hash` variable which is
# responsible for creating and exporting each shared directory.  It has the form:
#
# ```
#   share_hash => {
#     "directory_name" => {
#       client => client(share_option1,...,share_optionN) client(share_option1,...,share_optionN),
#       owner  => OWNER_OF_SHARE_DIR,
#       group  => GROUP_OF_SHARE_DIR,
#       mode   => MODE_OF_SHARE_DIR,
#     }
#   }
# ```
#
# @example real-world share_hash
#
# ```
#   share_hash => {
#     "/shared/foo" => {
#       "client" => "192.168.0.10(ro) 192.168.0.11(rw),
#     },
#     "/shared/bar" => {
#       "client" => "192.168.*(ro)",
#       "owner" => "bar",
#       "group" => "bar",
#       "mode    => "0770",
#     }
#     "/shared/special" => {
#       "client"     => "192.168.1.*(ro)",
#       "manage_dir" => false,
#     }
#   }
# ```
#
# @param package Name of nfs kernel server package to install
# @param manage_package true to manage the package with Puppet
# @param ensure_package State to ensure the package to
# @param share_hash Hash of shares to export (see above)
# @param default_share_owner Default owner of shares (override in hash)
# @param default_share_group Default group of shares (override in hash)
class nfs_server(
    $package                = $nfs_server::params::package,
    $manage_package         = true,
    $ensure_package         = present,
    $share_hash             = {},
    $default_owner          = "nobody",
    $default_group          = "nogroup",
    $default_mode           = "0770",
    $manage_service         = true,
    $service                = $nfs_server::params::service,
    $service_ensure         = running,
    $service_enable         = true,
    $exports                = "/etc/exports",
) inherits nfs_server::params {

  if $manage_package {
    package { $package:
      ensure => $ensure_package,
    }
  }

  file { "/etc/exports":
    ensure => file,
    owner  => "root",
    group  => "root",
    mode   => "0644",
  }

  $share_hash.each |$share_dir, $opts| {

    # manage the shared directory with puppet unless we were told not to (it
    # could be a mounted elsewhere)
    if pick($opts["manage_dir"],true) {
      file { $share_dir:
        ensure => directory,
        owner  => pick($opts['owner'], $default_owner),
        group  => pick($opts['group'], $default_group),
        mode   => pick($opts['mode'], $default_mode),
      }
    }

    # munge the line for /etc/exports
    file_line { "exports_for_${share_dir}":
      ensure => present,
      path   => $exports,
      line   => "${share_dir}\t${opts['client']}",
      match  => "^${share_dir}\t",
      notify => Exec["reload_nfs_exports"],
    }
  }

  exec { "reload_nfs_exports":
    command     => "exportfs -a",
    path        => ["/usr/sbin", "/sbin"],
    refreshonly => true,
  }


  if $manage_service {
    service { $service:
      ensure  => $service_ensure,
      enable  => $service_enable,
      require => Package[$package],
    }
  }
}
