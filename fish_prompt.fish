# Source
# https://github.com/brandon099/pure.fish

set fish_prompt_pwd_dir_length 0

function _format_time -d "Format milliseconds to a human readable format"
  set -l milliseconds $argv[1]
  set -l seconds (math -s0 "$milliseconds / 1000 % 60")
  set -l minutes (math -s0 "$milliseconds / 60000 % 60")
  set -l hours (math -s0 "$milliseconds / 3600000 % 24")
  set -l days (math -s0 "$milliseconds / 86400000")
  set -l time
  set -l threshold 5

  if test $days -gt 0
    set time (command printf "$time%sd " $days)
  end

  if test $hours -gt 0
    set time (command printf "$time%sh " $hours)
  end

  if test $minutes -gt 0
    set time (command printf "$time%sm " $minutes)
  end

  if test $seconds -gt $threshold
    set time (command printf "$time%ss " $seconds)
  end

  echo -e $time
end

function _in_git_directory
  git rev-parse --git-dir > /dev/null 2>&1
end

function _git_branch_name_or_revision
  set -l branch (git symbolic-ref HEAD ^ /dev/null | sed -e 's|^refs/heads/||')
  set -l revision (git rev-parse HEAD ^ /dev/null | cut -b 1-7)

  if test (count $branch) -gt 0
    echo $branch
  else
    echo $revision
  end
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

function _git_dirty
  set -l is_git_dirty (command git status --porcelain --ignore-submodules ^/dev/null)
  test -n "$is_git_dirty"
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

function _git_status
  set -l asterisk

  if _git_dirty
    set asterisk "$asterisk*"
  end

  echo $asterisk
end

function _print_in_color
  set -l string $argv[1]
  set -l color  $argv[2]

  set_color $color
  printf "$string"
  set_color normal
end

function _prompt_color_for_status
  if test $argv[1] -eq 0
    echo magenta
  else
    echo red
  end
end

function fish_prompt
  set -l last_status $status

  _print_in_color "\n"(prompt_pwd) blue


  # Show hostname if SSH'd in
  if set -q SSH_CONNECTION
    _print_in_color " "(prompt_hostname) brblack
  end

  # Show process run time if longer than 5 seconds
  if set -q CMD_DURATION
    if test $CMD_DURATION -gt 5000
        _print_in_color " "(_format_time $CMD_DURATION) yellow
    end
  end

  # Show Python virtual environment if enabled
  if set -q VIRTUAL_ENV
    _print_in_color " ("(basename "$VIRTUAL_ENV")")" brblack
  end

  # Show Kubernetes context and namespace in prompt if enabled
  if set -q __kube_ps_enabled
    if test $__kube_ps_enabled -eq 1
      _print_in_color (__kube_prompt) brblack
    end
  end

  # Show Git repository information if in a repository
  if _in_git_directory
    _print_in_color " \e[3m"(_git_branch_name_or_revision)"\e[0m" brblack
    _print_in_color (_git_status) yellow
    _print_in_color " "(_git_upstream_status) cyan
  end

  _print_in_color "\n❯ " (_prompt_color_for_status $last_status)

end
