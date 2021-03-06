#!/usr/bin/env bash

{ # This ensures the entire script is downloaded

# Config.
VPM_VERSION="2.4.0"
VPM_SOURCE=https://raw.githubusercontent.com/andrewscwei/vpm/v$VPM_VERSION/vpm.sh

# Colors.
COLOR_PREFIX="\x1b["
COLOR_RESET=$COLOR_PREFIX"0m"
COLOR_BLACK=$COLOR_PREFIX"0;30m"
COLOR_RED=$COLOR_PREFIX"0;31m"
COLOR_GREEN=$COLOR_PREFIX"0;32m"
COLOR_ORANGE=$COLOR_PREFIX"0;33m"
COLOR_BLUE=$COLOR_PREFIX"0;34m"
COLOR_PURPLE=$COLOR_PREFIX"0;35m"
COLOR_CYAN=$COLOR_PREFIX"0;36m"
COLOR_LIGHT_GRAY=$COLOR_PREFIX"0;37m"

# @global
#
# Checks if a command is available
#
# @param $1 Name of the command.
function VPM_HAS() {
  type "$1" > /dev/null 2>&1
}

# @global
#
# Gets the default install path. This can be overridden when calling the
# download script by passing the VPM_DIR variable.
function VPM_INSTALL_DIR() {
  printf %s "${VPM_DIR:-"$HOME/.vpm"}"
}

# Installs vpm as a script.
function vpm_install() {
  local dest="$(VPM_INSTALL_DIR)"

  mkdir -p "$dest"

  if [ -f "$dest/vpm.sh" ]; then
    echo -e "${COLOR_BLUE}vpm: vpm ${COLOR_ORANGE}is already installed in ${COLOR_CYAN}$dest${COLOR_ORANGE}, updating it instead...${COLOR_RESET}"
  else
    echo -e "${COLOR_BLUE}vpm: ${COLOR_RESET}Downloading ${COLOR_BLUE}vpm${COLOR_RESET} to ${COLOR_CYAN}$dest${COLOR_RESET}"
  fi

  # Download the script.
  curl --compressed -q -s "$VPM_SOURCE" -o "$dest/vpm.sh" || {
    echo >&2 "${COLOR_BLUE}vpm: ${COLOR_RED}Failed to download from ${COLOR_CYAN}$VPM_SOURCE${COLOR_RESET}"
    return 1
  }

  # Make script executable.
  chmod a+x "$dest/vpm.sh" || {
    echo >&2 "${COLOR_BLUE}vpm: ${COLOR_RED}Failed to mark ${COLOR_CYAN}$dest/vpm.sh${COLOR_RESET} as executable"
    return 3
  }
}

# Main process
function main() {
  # Download and install the script.
  if VPM_HAS curl; then
    vpm_install
  else
    echo >&2 "${COLOR_BLUE}vpm: ${COLOR_RED}You need ${COLOR_CYAN}curl${COLOR_RED} to install ${COLOR_BLUE}vpm${COLOR_RESET}"
    exit 1
  fi

  # Edit Bash and ZSH profile files to set up vpm.
  local dest="$(VPM_INSTALL_DIR)"
  local bashprofile=""
  local zshprofile=""
  local sourcestr="\nalias vpm='. ${dest}/vpm.sh'\n"

  if [ -f "$HOME/.bashrc" ]; then
    bashprofile="$HOME/.bashrc"
  elif [ -f "$HOME/.profile" ]; then
    bahsprofile="$HOME/.profile"
  elif [ -f "$HOME/.bash_profile" ]; then
    bashprofile="$HOME/.bash_profile"
  fi

  if [ -f "$HOME/.zshrc" ]; then
    zshprofile="$HOME/.zshrc"
  fi

  if [[ "$bashprofile" == "" ]] && [[ "$zshprofile" == "" ]]; then
    echo -e "${COLOR_BLUE}vpm: ${COLOR_RESET}Bash profile not found, tried ${COLOR_CYAN}~/.bashrc${COLOR_RESET}, ${COLOR_CYAN}~/.zshrc${COLOR_RESET}, ${COLOR_CYAN}~/.profile${COLOR_RESET} and ${COLOR_CYAN}~/.bash_profile${COLOR_RESET}"
    echo -e "     Create one of them and run this script again"
    echo -e "     OR"
    echo -e "     Append the following lines to the correct file yourself:"
    echo -e "     ${COLOR_CYAN}${sourcestr}${COLOR_RESET}"
    exit 1
  fi

  if [[ "$bashprofile" != "" ]]; then
    if ! command grep -qc '/vpm.sh' "$bashprofile"; then
      echo -e "${COLOR_BLUE}vpm: ${COLOR_RESET}Appending ${COLOR_BLUE}vpm${COLOR_RESET} source string to ${COLOR_CYAN}$bashprofile${COLOR_RESET}"
      command printf "${sourcestr}" >> "$bashprofile"
    else
      echo -e "${COLOR_BLUE}vpm: vpm ${COLOR_RESET}source string is already in ${COLOR_CYAN}$bashprofile${COLOR_RESET}"
    fi
  fi

  if [[ "$zshprofile" != "" ]]; then
    if ! command grep -qc '/vpm.sh' "$zshprofile"; then
      echo -e "${COLOR_BLUE}vpm: ${COLOR_RESET}Appending ${COLOR_BLUE}vpm${COLOR_RESET} source string to ${COLOR_CYAN}$zshprofile${COLOR_RESET}"
      command printf "${sourcestr}" >> "$zshprofile"
    else
      echo -e "${COLOR_BLUE}vpm: vpm ${COLOR_RESET}source string is already in ${COLOR_CYAN}$zshprofile${COLOR_RESET}"
    fi
  fi

  # Source vpm
  \. "$dest/vpm.sh"

  echo -e "${COLOR_BLUE}vpm: ${COLOR_GREEN}Installation complete. Close and reopen your terminal to start using ${COLOR_BLUE}vpm${COLOR_RESET}"
}

main

} # This ensures the entire script is downloaded