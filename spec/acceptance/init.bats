if [[ -f /etc/redhat-release ]] ; then
    DAEMON="nfs-server"
    DEFAULT_OWNER="nfsnobody"
    DEFAULT_GROUP="nfsnobody"
else
    DAEMON="nfs-kernel-server"
    DEFAULT_OWNER="nobody"
    DEFAULT_GROUP="nogroup"
fi

@test "service operational" {
    systemctl status $DAEMON
}

#
# /scratch/foo
#

@test "default user permission on /scratch/foo" {
    [[ $(stat -c %U /scratch/foo) == $DEFAULT_OWNER ]]
}
@test "default group on /scratch/foo" {
    [[ $(stat -c %G /scratch/foo) == $DEFAULT_GROUP ]]
}
@test "default mode on shared dir" {
    [[ $(stat -c %a /scratch/foo) == "770" ]]
}
@test "/scratch/foo added to exports" {
    grep /scratch/foo /etc/exports
}

#
# /scratch/bar
#

@test "set user permission on /scratch/bar" {
    [[ $(stat -c %U /scratch/bar) == "foo" ]]
}
@test "set group on /scratch/bar" {
    [[ $(stat -c %G /scratch/bar) == "bar" ]]
}
@test "default mode on shared dir" {
    [[ $(stat -c %a /scratch/bar) == "755" ]]
}
@test "/scratch/bar added to exports" {
    grep /scratch/bar /etc/exports
}

#
# /scratc/testcase - functional test
#

@test "/scratch/testcase added to exports" {
    grep /scratch/testcase /etc/exports
}

@test "mount an nfs share from /scratch/testcase" {
    mount localhost:/scratch/testcase /tmp/testcase_mount
}

@test "read a file from mounted nfs share" {
    grep hello /tmp/testcase_mount/test
}