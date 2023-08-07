{ config, lib, pkgs, ... }:

let cfg = config.personal-infrastructure.postgresql;
    users = cfg.users;

    options = {
      enable = lib.mkEnableOption "Postgresql service with user & db provisioning";
      users = lib.mkOption {
        type = lib.types.attrsOf userType;
        default = {};
      };
    };

    userType = lib.types.submodule {
      options = {
        databases = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          description = "databases for this user. The databases will be created.";
          default = [];
        };

        superuser = lib.mkOption {
          type = lib.types.bool;
          default = false;
        };

        initialPassword = lib.mkOption {
          type = lib.types.str;
          description = "Password hashed with scram-sha-256.";
        };
      };
    };

    service = {
      enable = true;
      inherit authentication ensureDatabases ensureUsers;
    };

    authentication = lib.strings.concatMapStrings authenticate (builtins.attrNames users);

    authenticate = userName: ''
      local all ${userName} scram-sha-256
    '';

    ensureDatabases = lib.lists.unique (lib.lists.concatMap (u: u.databases) (builtins.attrValues users));

    ensureUsers = lib.attrsets.mapAttrsToList buildUser users;

    buildUser = name: def: {
      inherit name;
      ensurePermissions = ensurePermissions def;
      ensureClauses     = ensureClauses     def;
    };

    ensurePermissions = def: lib.lists.foldr buildPermission {} def.databases;

    buildPermission = database: acc:
      acc // {
        "DATABASE ${database}" = "ALL PRIVILEGES";
      };

    ensureClauses = def: {
      inherit (def) superuser;
      createrole = def.superuser;
      createdb   = def.superuser;
    };

    setPasswords = ''
      $PSQL -tAf ${setPasswordsSQLFile}
    '';

    setPasswordsSQLFile =
      pkgs.writeText "set-passwords.sql"
      (lib.strings.concatStrings (lib.attrsets.mapAttrsToList mkAlterRoleStatement users));

    mkAlterRoleStatement = name: def: ''
      ALTER ROLE "${name}" WITH PASSWORD '${def.initialPassword}';
    '';
in
{
  options.personal-infrastructure.postgresql = options;

  config = lib.mkIf cfg.enable {
    services.postgresql = service;
    systemd.services.postgresql.postStart = setPasswords;
  };
}
