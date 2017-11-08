#@PDQTest
file { "/shared":
  ensure => directory,
  owner  => "root",
  group  => "root",
  mode  => "0755",
}
class { "nfs_server":
  share_hash => {
    "/scratch/foo" => {
      "client" => "192.168.0.10(ro) 192.168.0.11(rw)",
    },
    "/scratch/bar" => {
      "client" => "192.168.*(ro)",
      "owner"  => "foo",
      "group"  => "bar",
      "mode"   => "0755",
    },
    "/scratch/testcase" => {
      "client"     => "*(ro)",
      "manage_dir" => false,
    },
  }
}
