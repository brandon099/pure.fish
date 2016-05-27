# Settings for Git Prompt
set __fish_git_prompt_showdirtystate 'yes'
set __fish_git_prompt_showupstream 'informative'
set __fish_git_prompt_color_dirtystate yellow
set __fish_git_prompt_char_upstream_ahead '↑'
set __fish_git_prompt_char_upstream_behind '↓'
#set __fish_git_prompt_char_upstream_diverged '↑↓'

function _pwd_with_tilde
  echo $PWD | sed 's|^'$HOME'\(.*\)$|~\1|'
end

function _prompt_hostname
  echo $USER"@"(cat /etc/hostname 2>/dev/null; or hostname | cut -d . -f 1)
end

function _format_time -d "Format milliseconds to a human readable format"
  set -l milliseconds $argv[1]
  set -l seconds (math "$milliseconds / 1000 % 60")
  set -l minutes (math "$milliseconds / 60000 % 60")
  set -l hours (math "$milliseconds / 3600000 % 24")
  set -l days (math "$milliseconds / 86400000")
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

  # If in git repo, show info about repo
  if _in_git_directory
    _print_in_color (__fish_git_prompt) cyan
  end

  # Show user@hostname if SSH'd in
  if set -q SSH_CONNECTION
    _print_in_color " "(_prompt_hostname) 65737E
  end

  # Show process run time if longer than 5 seconds
  if set -q CMD_DURATION
    if test $CMD_DURATION -gt 5000
        _print_in_color " "(_format_time $CMD_DURATION) yellow
    end
  end

  # Show prompt, with Python Virtualenv support
  if set -q VIRTUAL_ENV
    _print_in_color "\n("(basename "$VIRTUAL_ENV")")" normal
    _print_in_color "❯ " (_prompt_color_for_status $last_status)
  else
    _print_in_color "\n❯ " (_prompt_color_for_status $last_status)
  end

end
