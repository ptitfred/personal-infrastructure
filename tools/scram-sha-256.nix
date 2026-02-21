{ buildGoModule, inputs, writeShellApplication }:

let scram-sha-256 = buildGoModule {
      name = "scram-sha-256";
      src = inputs.scram-sha-256;
      vendorHash = "sha256-L7nK+w4CB2H3b6vL0ZoFfaRMgCmpqzQo8ThMM60C76I=";
    };
 in writeShellApplication {
       name = "scram-sha-256";
       text = ''
          ${scram-sha-256}/bin/term
       '';
    }
