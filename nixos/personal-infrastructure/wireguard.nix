{ config, lib, nodes, ... }:

let otherPeersOpts = with lib; {
      options = {
        publicKey = publicKeyOpt;

        allowedIPs = mkOption {
          example = [ "10.192.122.3/32" "10.192.124.1/24" ];
          type = with types; listOf str;
          description = lib.mdDoc ''List of IP (v4 or v6) addresses with CIDR masks from
          which this peer is allowed to send incoming traffic and to which
          outgoing traffic for this peer is directed. The catch-all 0.0.0.0/0 may
          be specified for matching all IPv4 addresses, and ::/0 may be specified
          for matching all IPv6 addresses.'';
        };
      };
    };

    publicKeyOpt = with lib; mkOption {
      example = "xTIBA5rboUvnH4htodjb6e697QjLERt1NAB4mZqp8Dg=";
      type = types.str;
      description = lib.mdDoc "The base64 public key of the peer.";
    };

in
{
  options = with lib; {
    personal-infrastructure.tissue = {
      publicKey = publicKeyOpt;

      ip = mkOption {
        type = types.str;
        example = "10.100.12.34";
      };

      hosts = mkOption {
        type = types.listOf types.str;
        default = [];
      };

      listenIp = mkOption {
        type = types.str;
        example = "1.2.3.4";
      };

      clients = mkOption {
        type = types.listOf types.str;
        default = [];
      };

      other-peers = mkOption {
        type = types.listOf (types.submodule otherPeersOpts);
        default = [];
        example = [ { publicKey = "522Qq1oUTefraap0xh/UdVsGeRGS+H8vS3+QAciQths="; allowedIPs = [ "10.100.12.34/32" ]; } ];
      };

      reachable = mkOption {
        type = types.bool;
        default = false;
      };

      open-ports = mkOption {
        type = types.listOf types.int;
        default = [];
      };
    };
  };

  config = {
    networking =
      let wg-interface = "tissue";
          cfg = config.personal-infrastructure.tissue;
          isServer = builtins.length cfg.clients > 0;
          isClient = builtins.length cfg.hosts > 0;
          mkPeer = hostname:
            let cfg' = nodes.${hostname}.config.personal-infrastructure.tissue;
            in
              {
                inherit (cfg') publicKey;
                allowedIPs = [ "${cfg'.ip}/32" ];
              };

          mkHostAlias = hostname:
            let ip' = nodes.${hostname}.config.personal-infrastructure.tissue.ip;
                alias = "${hostname}.${wg-interface}";
            in _: { "${ip'}" = alias; };

          mkServerPeer = host:
            let server = nodes.${host}.config.personal-infrastructure.tissue.listenIp;
                serverListenPort = nodes.${host}.config.networking.wireguard.interfaces.${wg-interface}.listenPort;
             in {
                  publicKey = nodes."${host}".config.personal-infrastructure.tissue.publicKey;
                  allowedIPs = [ "10.100.0.0/24" ];
                  endpoint = "${server}:${toString serverListenPort}";

                  persistentKeepalive =
                    if cfg.reachable
                    then
                      # Useful if we want mobile devices to be able to reach this machine behind NAT
                      25
                    else null;
                };

          collectHostAliases = lib.attrsets.foldAttrs (n: a: [n] ++ a) [];

          hostAliases = lib.attrsets.mapAttrsToList mkHostAlias (lib.attrsets.filterAttrs (n: _: n ? "config") nodes);
      in
        {
          hosts = collectHostAliases hostAliases;

          nat = lib.modules.mkIf isServer {
            enable = true;
            externalInterface = "eth0";
            internalInterfaces = [ wg-interface ];
          };

          firewall.allowedUDPPorts = lib.modules.mkIf isServer [ config.networking.wireguard.interfaces.${wg-interface}.listenPort ];

          wireguard.interfaces = {
            "${wg-interface}" = {
              ips = [ "${cfg.ip}/24" ];
              listenPort = lib.modules.mkIf isServer 51820;

              privateKeyFile = "${config.deployment.keys.wg-private-key.destDir}/wg-private-key";
              peers =
                map mkServerPeer cfg.hosts
                ++ lib.lists.optionals isClient (map mkPeer cfg.clients ++ cfg.other-peers);
            };
          };

          firewall.interfaces."${wg-interface}".allowedTCPPorts = lib.modules.mkIf cfg.reachable cfg.open-ports;
        };
  };

}
