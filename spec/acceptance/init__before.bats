@test "test user foo exists" {
    grep foo /etc/passwd
}

@test "test user bar exists" {
    grep foo /etc/passwd
}

@test "test group foo exists" {
    grep foo /etc/group
}

@test "test group bar exists" {
    grep foo /etc/group
}
