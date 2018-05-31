#!/usr/bin/env bash

# plugin
# Plugin usage:
#   led open [OPTIONS] NAME [URL]
#
# Without URL, the bookmark NAME will be open in your browser.
# With URL, the bookmark NAME will be stored.
#
# Options
#   -d, --display   The bookmark instead open
#   -g, --global    Bookmark in global configuration, at user level so
#   -l, --list      Show all bookmarks configured
#   -n, --name      Only display all bookmaks name
#   -s, --system    Bookmark in system configuration if you dare
#
# @autocomplete open: [led open -n] --display --list --global --system --quiet
open_plugin() {
  local display=false list=false name=false level bookmark bookmark_url key \
    prefix="open."

  level=${level:-1}

  # shellcheck disable=SC2046
  set -- $(_lib_utils_get_options "nlgsd" "list,global,system,display,name" "$@")

  while [ ! -z "$#" ]; do
    case $1 in
      -l | --list)
        list=true
        shift
        ;;
      -n | --name)
        name=true
        shift
        ;;
      -s | --system)
        level=3
        shift
        ;;
      -g | --global)
        level=2
        shift
        ;;
      -d | --display)
        display=true
        shift
        ;;
      --)
        shift
        break
        ;;
      -*)
        echo "bad option:$1"
        shift
        break
        ;;
    esac
  done

  if [[ "$list" == true ]] || [[ "$name" == true ]]; then

    for key in $(_config_get_keys "${prefix}" true); do
      if [[ "$name" == true ]]; then
      echo "$key"
      else
        print_padded "$key" "$(_config_get_value "${prefix}${key}")"
      fi
    done
    exit
  fi
  IFS=" " read -r bookmark bookmark_url <<<"$@"

  if [ -z "${bookmark}" ]; then
    help plugin open
    exit 1
  fi

  key="${prefix}${bookmark}"

  if [[ -z "${bookmark_url}" ]]; then
    bookmark_url=$(_config_get_value "${key}")
    if [ -z "${bookmark_url}" ]; then
      echo "The bookmark ${key} does not exist"
      exit 1
    fi
    if [[ "${display}" == true ]]; then
      echo "${bookmark_url}"
    else
      # open bookmark in default browser
      xdg-open "${bookmark_url}" &>/dev/null
    fi
  else
    # set the bookmark
    _config_set_value ${key} "${bookmark_url}" -l "${level}"
  fi

}
