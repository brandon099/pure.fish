function _pwd_with_tilde
  echo $PWD | sed 's|^'$HOME'\(.*\)$|~\1|'
end

function _prompt_hostname
  echo $USER"@"(hostname | cut -d . -f 1)
end

function _in_git_directory
  git rev-parse --git-dir > /dev/null 2>&1
end

function _git_upstream_configured
  git rev-parse --abbrev-ref @"{u}" > /dev/null 2>&1
end

function _git_behind_upstream
  test (git rev-list --right-only --count HEAD...@"{u}" ^ /dev/null) -gt 0
end

function _git_ahead_of_upstream
  test (git rev-list --left-only --count HEAD...@"{u}" ^ /dev/null) -gt 0
end

function _git_upstream_status
  set -l arrows

  if _git_upstream_configured
    if _git_behind_upstream
      set arrows "$arrows⇣"
    end

    if _git_ahead_of_upstream
      set arrows "$arrows⇡"
    end
  end

  echo $arrows
end

function _print_in_color
  set -l string $argv[1]
  set -l color  $argv[2]

  set_color $color
  printf $string
  set_color normal
end

function _prompt_color_for_status
  if test $argv[1] -eq 0
    echo normal
  else
    echo red
  end
end

function fish_prompt
  set -l last_status $status

  _print_in_color "\n"(_pwd_with_tilde) blue

  if _in_git_directory
    _print_in_color (__fish_git_prompt) cyan
    _print_in_color " "(_git_upstream_status) cyan
  end

  if [ $SSH_CONNECTION ]
      _print_in_color " "(_prompt_hostname) 65737E
  end

  if set -q VIRTUAL_ENV
      _print_in_color "\n("(basename "$VIRTUAL_ENV")")" normal
      _print_in_color "❯ " (_prompt_color_for_status $last_status)
  else
      _print_in_color "\n❯ " (_prompt_color_for_status $last_status)
  end
end
