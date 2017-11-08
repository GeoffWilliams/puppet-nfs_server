# Nfs_server::Params
#
# Params pattern for Nfs_server
class nfs_server::params {

  case $facts['os']['family'] {
    "RedHat": {
      $package = "nfs-utils"
      $service = "nfs-server"
      $default_owner   = "nfsnobody"
      $default_group   = "nfsnobody"
    }
    "Debian": {
      $package = "nfs-kernel-server"
      $service = "nfs-kernel-server"
      $default_owner   = "nobody"
      $default_group   = "nogroup"
    }
    default: {
      fail("${module_name} does not support ${facts['os']['family']} yet - please consider a PR")
    }

  }
}