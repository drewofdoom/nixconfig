{ pkgs, lib, ... }:

{
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    defaultEditor = true;

    plugins = with pkgs.vimPlugins; [
      base16-nvim
      mini-nvim
      which-key-nvim
      plenary-nvim
      telescope-nvim
      (nvim-treesitter.withPlugins (p: [
        p.bash
        p.c
        p.lua
        p.markdown
        p.nix
      ]))
      vim-sleuth
      comment-nvim
    ];

    extraLuaConfig = ''
      -- Noctalia theme (generated at ~/.config/nvim/lua/matugen.lua).
      -- Guard with pcall so nvim still starts if the template hasn't run yet.
      local ok, matugen = pcall(require, 'matugen')
      if ok then
        matugen.setup()
      end

      -- Sensible defaults for occasional use
      vim.opt.number = true
      vim.opt.ignorecase = true
      vim.opt.smartcase = true
      vim.opt.undofile = true
      vim.opt.termguicolors = true
      vim.opt.scrolloff = 5

      require('mini.surround').setup()
      require('mini.pairs').setup()
      require('mini.statusline').setup()
      require('which-key').setup()
      require('Comment').setup()
      require('nvim-treesitter.configs').setup({
        highlight = { enable = true },
        indent = { enable = true },
      })
    '';
  };

  # GUI editor for VISUAL (waits so git commits etc. work); EDITOR stays nvim
  # via defaultEditor above. mkForce wins over defaultEditor's own VISUAL.
  home.sessionVariables.VISUAL = lib.mkForce "zeditor --wait";
}
