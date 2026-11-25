{ buildGoModule, inputs, writeShellApplication }:

let scram-sha-256 = buildGoModule {
      name = "scram-sha-256";
      src = inputs.scram-sha-256;
      vendorHash = "sha256-/mTZkvmdSfFR+tBxuUKdDVqpxVAU7vxtcBS2yz2WBjI=";
    };
 in writeShellApplication {
       name = "scram-sha-256";
       text = ''
          ${scram-sha-256}/bin/term
       '';
    }
