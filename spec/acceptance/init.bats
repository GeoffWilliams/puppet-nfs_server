@test "service operational" {
    systemctl status nfs-kernel-server
}

#
# /shared/foo
#

@test "default user permission on /shared/foo" {
    [[ $(stat -c %U /shared/foo) == "nobody" ]]
}
@test "default group on /shared/foo" {
    [[ $(stat -c %G /shared/foo) == "nogroup" ]]
}
@test "default mode on shared dir" {
    [[ $(stat -c %a /shared/foo) == "770" ]]
}
@test "/shared/foo added to exports" {
    grep /shared/foo /etc/exports
}

#
# /shared/bar
#

@test "set user permission on /shared/bar" {
    [[ $(stat -c %U /shared/bar) == "foo" ]]
}
@test "set group on /shared/bar" {
    [[ $(stat -c %G /shared/bar) == "bar" ]]
}
@test "default mode on shared dir" {
    [[ $(stat -c %a /shared/bar) == "755" ]]
}
@test "/shared/bar added to exports" {
    grep /shared/bar /etc/exports
}

#
# /shared/special
#
@test "unmanaged shared dir should not be created" {
    [[ ! -d /shared/special ]]
}

@test "/shared/special added to exports" {
    grep /shared/special /etc/exports
}
