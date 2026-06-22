server_01.start()
server_01.wait_for_unit("nginx.service")

with subtest("NGinx configuration"):
  server_01.succeed("http --check-status --follow http://long.test.localhost/")
  server_01.succeed("http --check-status --follow http://long.test.localhost/example")
  server_01.succeed("http --check-status --follow http://long.test.localhost/example/")
  server_01.succeed("http --check-status --follow http://test.localhost/")
  server_01.succeed("http --check-status --follow http://test.localhost/example")
  server_01.succeed("http --check-status --follow http://test.localhost/example/")

with subtest("Lix"):
  server_01.succeed("nix --version | grep 'Lix'")
  server_01.succeed("nix --version | grep '2.94'")

  server_01.succeed("which colmena")

  # Recent version of colmena expect a configuration file event for nix-info. This is a bug.
  server_01.execute("touch hive.nix")

  server_01.succeed("RUST_LOG=info colmena nix-info 2>&1 | grep 'Nix Version: 2.94'")
