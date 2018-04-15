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
#     "/scratch/foo" => {
#       "client" => "192.168.0.10(ro) 192.168.0.11(rw)",
#     },
#     "/scratch/bar" => {
#       "client" => "192.168.*(ro)",
#       "owner"  => "foo",
#       "group"  => "bar",
#       "mode"   => "0755",
#     },
#     "/scratch/testcase" => {
#       "client"     => "*(ro)",
#       "manage_dir" => false,
#     },
# ```
#
# @param package Name of nfs kernel server package to install
# @param manage_package `true` to manage the package with Puppet
# @param ensure_package State to ensure the package to
# @param share_hash Hash of shares to export (see above)
# @param default_owner Default owner of shares (override in hash)
# @param default_group Default group of shares (override in hash)
# @param default_mode Default mode of shares (override in hash)
# @param manage_service `true` to manage the service with Puppet
# @param service Name of the nfs service on this system
# @param service_ensure State to ensure the service to (if managed)
# @param service_enable `true` to start the service on boot
# @param exports location of the `exports` file (usually /etc/exports)
class nfs_server(
    String                $package        = $nfs_server::params::package,
    Boolean               $manage_package = true,
    Enum[present,absent]  $ensure_package = present,
    Hash                  $share_hash     = {},
    String                $default_owner  = $nfs_server::params::default_owner,
    String                $default_group  = $nfs_server::params::default_group,
    String                $default_mode   = "0770",
    Boolean               $manage_service = true,
    String                $service        = $nfs_server::params::service,
    Enum[running,stopped] $service_ensure = running,
    Boolean               $service_enable = true,
    String                $exports        = "/etc/exports",
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
      $mode = pick($opts['mode'], $default_mode)
      file { $share_dir:
        ensure => directory,
        owner  => pick($opts['owner'], $default_owner),
        group  => pick($opts['group'], $default_group),
        mode   => $mode,
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

  if $manage_service {
    $service_require = Service[$service]

    service { $service:
      ensure  => $service_ensure,
      enable  => $service_enable,
      require => Package[$package],
    }
  } else {
    $service_require = undef
  }

  exec { "reload_nfs_exports":
    command     => "exportfs -a",
    path        => ["/usr/sbin", "/sbin"],
    refreshonly => true,
    require     => $service_require,
  }

}
