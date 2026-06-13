{ config, pkgs, lib, ... }:

let inherit (lib) mkOption types;
    loadLuaConfigFiles = lib.strings.concatMapStrings builtins.readFile;
in
{
  options = {
    programs.neovim.luaConfigFiles = mkOption {
      type = with types; listOf path;
      default = [];
    };
  };

  config = {
    home.sessionVariables = {
      EDITOR = "vim";
    };

    programs.bash.shellAliases = {
      ":e" = "vim";
    };

    home.packages = with pkgs; [
      xclip
      libxml2
      gh
      rumdl
      lua-language-server
      nil
      bash-language-server
      shellcheck
      elixir-ls
      typescript-language-server
      vscode-langservers-extracted
      luaPackages.tree-sitter-cli
    ];

    programs.neovim = {
      enable = true;
      vimAlias = true;
      extraConfig = builtins.readFile ./config.vim;
      luaConfigFiles = [
        ./config.lua
        ./completions.lua
        ./lsp-config.lua
        ./hover.lua
      ];
      initLua = loadLuaConfigFiles config.programs.neovim.luaConfigFiles;
      plugins =
        with pkgs.vimPlugins;
          [
            cmp-buffer
            cmp-cmdline
            cmp-git
            cmp-nvim-lsp
            cmp-nvim-lsp-signature-help
            cmp-omni
            cmp-path
            cmp-spell
            comment-nvim
            fidget-nvim
            gruvbox
            vim-airline
            vim-autoformat
            vim-polyglot
            vim-vsnip
            lspkind-nvim
            nvim-autopairs
            nvim-cmp
            nvim-lspconfig
            hover-nvim
            telescope-nvim
            telescope-fzf-native-nvim
            telescope-lsp-handlers-nvim
            telescope-ui-select-nvim
            # Tree-sitter now compiles the parsers and stores in
            # `~/.local/share/nvim/site/`, added to impermanence
            {
              plugin = nvim-treesitter;
              type = "lua";
              config = builtins.readFile ./treesitter.lua;
            }
            nvim-treesitter-parsers.bash
            nvim-treesitter-parsers.elixir
            nvim-treesitter-parsers.lua
            nvim-treesitter-parsers.nix
            nvim-treesitter-parsers.rust
            nvim-treesitter-parsers.wgsl
            nvim-treesitter-parsers.wgsl_bevy
            hurl
          ];
      withPython3 = false;
      withRuby = false;
    };
  };
}
