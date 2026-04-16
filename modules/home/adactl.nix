{ pkgs, ... }:

{
  # Wrapper script that delegates to the local Quarkus native-image runner
  home.packages = [
    (pkgs.writeShellScriptBin "adactl" ''
      exec "$HOME/workspace/adactl/target/adactl-1.0-SNAPSHOT-runner" "$@"
    '')
  ];

  programs.zsh.initContent = ''
    # adactl — bash-style completion via bashcompinit
    autoload -U +X bashcompinit && bashcompinit
    eval "$(adactl generate-completion 2>/dev/null)"

    # adactl — fzf fuzzy completion for tags and topics
    _fzf_complete_adactl() {
      local words=(''${(z)LBUFFER})
      local current_word=''${words[-1]}

      if [[ $current_word == -* ]]; then
        return
      fi

      if [[ (''${words[2]} == "get" && ''${words[3]} == ("tags"|"stats"|"summary"|"metadata")) || ''${words[2]} == "query" ]]; then
        _fzf_complete --height=40% --reverse -- "$@" < <(
          adactl get tags 2>/dev/null
        )
      elif [[ ''${words[2]} == "consume" ]]; then
        _fzf_complete --height=40% --reverse -- "$@" < <(
          adactl get topics 2>/dev/null
        )
      fi
    }
  '';
}
