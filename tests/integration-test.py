server_01.start()
server_01.wait_for_unit("nginx.service")

with subtest("NGinx configuration"):
  server_01.succeed("http --check-status --follow http://long.test.localhost/")
  server_01.succeed("http --check-status --follow http://long.test.localhost/example")
  server_01.succeed("http --check-status --follow http://long.test.localhost/example/")
  server_01.succeed("http --check-status --follow http://test.localhost/")
  server_01.succeed("http --check-status --follow http://test.localhost/example")
  server_01.succeed("http --check-status --follow http://test.localhost/example/")
