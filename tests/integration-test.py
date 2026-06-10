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
  server_01.succeed("nix --version | grep '2.93'")
  server_01.succeed("which colmena")
  server_01.succeed("colmena nix-info 2>&1 | grep 'Nix Version: 2.93'")
