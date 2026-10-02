# Git configuration.
#
# Identity and default branch only. Git remotes for the tailnet Gitea use the
# MagicDNS hostname directly -- ssh://git@gitea:22/owner/name -- with no
# insteadOf alias: the rewrite only saved keystrokes on the initial clone and
# was then baked into .git/config anyway, so it bought indirection and a
# confusing "does not appear to be a git repository" failure for nothing.
{ ... }:

{
  programs = {
    git = {
      enable = true;

      settings = {
        init.defaultBranch = "main";

        # Identity. These were previously set imperatively in ~/.gitconfig and
        # are now declarative; home-manager drops the imperative copy on
        # activation.
        user.name = "Drew DeVore";
        user.email = "drew@devorcula.com";
      };
    };

    gh = {
      enable = true;
      settings.git_protocol = "ssh";
    };
  };
}
