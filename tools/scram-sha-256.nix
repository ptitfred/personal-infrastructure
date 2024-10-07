{ buildGoModule, inputs, writeShellApplication }:

let scram-sha-256 = buildGoModule {
      name = "scram-sha-256";
      src = inputs.scram-sha-256;
      vendorHash = "sha256-HjyD30RFf5vnZ8CNU1s3sTTyCof1yD8cdVWC7cLwjic=";
    };
 in writeShellApplication {
       name = "scram-sha-256";
       text = ''
          ${scram-sha-256}/bin/term
       '';
    }
