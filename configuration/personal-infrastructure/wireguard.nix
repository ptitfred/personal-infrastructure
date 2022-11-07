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

      host = mkOption {
        type = types.nullOr types.str;
        default = null;
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

      joinable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };

  config = {
    networking =
      let wg-interface = "tissue";
          cfg = config.personal-infrastructure.tissue;
          isServer = builtins.length cfg.clients > 0;
          isClient = builtins.isString cfg.host;
          server = nodes.${cfg.host}.config.personal-infrastructure.tissue.listenIp;
          serverListenPort = nodes.${cfg.host}.config.networking.wireguard.interfaces.${wg-interface}.listenPort;
          mkPeer = hostname:
            let cfg' = nodes.${hostname}.config.personal-infrastructure.tissue;
            in
              {
                inherit (cfg') publicKey;
                allowedIPs = [ "${cfg'.ip}/32" ];
              };
      in
        {
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

              privateKeyFile = config.deployment.secrets.wg-private-key.destination;
              peers =
                if isServer
                then (map mkPeer cfg.clients ++ cfg.other-peers)
                else lib.modules.mkIf isClient
                  [
                    {
                      publicKey = nodes."${cfg.host}".config.personal-infrastructure.tissue.publicKey;
                      allowedIPs = [ "10.100.0.0/24" ];
                      endpoint = "${server}:${toString serverListenPort}";

                      persistentKeepalive =
                        if cfg.joinable
                        then
                          # Useful if we want mobile devices to be able to reach this machine behind NAT
                          25
                        else null;
                    }
                  ];
            };
          };
        };

  };

}
