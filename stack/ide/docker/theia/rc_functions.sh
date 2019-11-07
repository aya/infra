# force a command to run and restart it when it exits
force () {
    PS_X_FIELD=1
    if [ $# -gt 0 ]; then
        # awk expression to match $@
        while true; do
            [ $(ps wwx -o args |awk '
                BEGIN {nargs=split("'"$*"'",args)}
                $field == args[1] {
                    matched=1;
                    for (i=1;i<=NF-field;i++) {
                        if ($(i+field) == args[i+1]) {matched++}
                    }
                    if (matched == nargs) {found++}
                }
                END {print found+0}' field="${PS_X_FIELD}") -eq 0 ] \
            && "$@" || sleep 1;
        done
    fi
}

# start an ssh agent and add any private key in ~/.ssh
ssh_agent () {
    command -v ssh-agent >/dev/null 2>&1 && command -v ssh-add >/dev/null 2>&1 || return
    SSH_AGENT_DIR="/tmp/ssh-$(id -u)"
    SSH_AGENT_SOCK="${SSH_AGENT_DIR}/agent@$(hostname |sed 's/\..*//')"
    [ -z "${SSH_AUTH_SOCK}" ] \
     && { [ -d "${SSH_AGENT_DIR}" ] || { mkdir "${SSH_AGENT_DIR}" 2>/dev/null && chmod 0700 "${SSH_AGENT_DIR}"; } } \
     && [ $(ps wwx -o args |awk '$1 == "ssh-agent" && $3 == "'"${SSH_AGENT_SOCK}"'"' |wc -l) -eq 0 ] \
     && rm -f "${SSH_AGENT_SOCK}" \
     && ssh-agent -a "${SSH_AGENT_SOCK}" >/dev/null 2>&1
    export SSH_AUTH_SOCK="${SSH_AUTH_SOCK:-${SSH_AGENT_SOCK}}"
    (echo "${HOME}"/.ssh/id_rsa; grep -l 'PRIVATE KEY' "${HOME}"/.ssh/* |grep -vE "^${HOME}/.ssh/id_rsa$") |while read -r file; do
        [ -r "${file}" ] && [ -z "$(ssh-add -l |awk '{print $3}' |grep -E "^${file}$")" ] && ssh-add "${file}"
    done
    unset SSH_AGENT_DIR SSH_AGENT_SOCK
}

# attach an existing screen or create a new one
attach_screen () {
    command -v screen >/dev/null 2>&1 || return
    if [ -z "${STY}" ]; then
        # attach screen in tmux window 0
        [ -n "${TMUX}" ] && [ "$(tmux list-window 2>/dev/null |awk '$NF == "(active)" {print $1}' |sed 's/:$//')" != "0" ] && return
        /bin/echo -n 'Attaching screen.' && sleep 1 && /bin/echo -n '.' && sleep 1 && /bin/echo -n '.' && sleep 1 && screen -xRR -S "$(id -nu)" 2>/dev/null
    fi
}

# attach an existing tmux or create a new one
attach_tmux () {
    command -v tmux >/dev/null 2>&1 || return
    SESSION_NAME="$(id -nu)@$(hostname |sed 's/\..*//')"
    if [ -z "${TMUX}" ]; then
        /bin/echo -n 'Attaching tmux.' && sleep 1 && /bin/echo -n '.' && sleep 1 && /bin/echo -n '.' && sleep 1 && tmux -L"${SESSION_NAME}" -q has-session >/dev/null 2>&1 && tmux -L"${SESSION_NAME}" attach-session -d || tmux -L"${SESSION_NAME}" new-session -s"${SESSION_NAME}"
    fi
}

# echo the "number of running processes"/"total number of processes"/"number of processes in D-state"
process_count () {
    ps ax -o stat 2>/dev/null |awk '$1 ~ /R/ {r_processes++}; $1 ~ /D/ {d_processes++}; END {print r_processes+0"/"d_processes+0"/"NR-1}'
}

# echo the "number of distinct logged in users"/"number of logged in users"/"number of distinct users running processes"
user_count () {
    ps ax -o user,tty,comm 2>/dev/null |awk '$2 !~ /^\?/ && $3 !~ /getty$/ {l_users[$2]++; d_users[$1]++}; {p_users[$1]++}; END {print length(d_users)-1"/"length(l_users)-1"/"length(p_users)-1}'
}

# echo the load average
load_average () {
    awk '{print $1}' /proc/loadavg 2>/dev/null || uptime 2>/dev/null |awk '{print $(NF-2)}'
}

# export PS1
custom_ps1 () {
    case "$0" in
      sh)
        HOSTNAME="$(hostname)"
        USER="$(id -nu)"
        ;;
      *ash)
        DGRAY="\[\033[1;30m\]"
        RED="\[\033[01;31m\]"
        GREEN="\[\033[01;32m\]"
        BROWN="\[\033[0;33m\]"
        YELLOW="\[\033[01;33m\]"
        BLUE="\[\033[01;34m\]"
        CYAN="\[\033[0;36m\]"
        GRAY="\[\033[0;37m\]"
        NC="\[\033[0m\]"
        ;;
      *)
        ;;
    esac

    if [ "$(id -u)" = 0 ]; then
        COLOR=${RED}
        END="#"
    else
        COLOR=${BROWN}
        END="\$"
    fi

    COUNT="${DGRAY}[${BLUE}\$(user_count 2>/dev/null)${DGRAY}|${BLUE}\$(process_count 2>/dev/null)${DGRAY}|${BLUE}\$(load_average 2>/dev/null)${DGRAY}]"

    type __git_ps1 >/dev/null 2>&1 \
     && GIT="\$(__git_ps1 2>/dev/null \" (%s)\")" \
     || GIT="\$(BRANCH=\$(git rev-parse --abbrev-ref HEAD 2>/dev/null); [ -n \"\${BRANCH}\" ] && echo \" (\${BRANCH})\")"

    export PS1="${COUNT}${COLOR}${USER}${DGRAY}@${CYAN}${HOSTNAME%%.*}${DGRAY}:${GRAY}\$(pwd |sed 's|^${HOME}\(/.*\)*$|~\1|')${CYAN}${GIT}${DGRAY}${END}${NC} "
}

# export PROMPT_COMMAND
custom_prompt () {
    case "${TERM}" in
      screen*)
        ESCAPE_CODE_DCS="\033k"
        ESCAPE_CODE_ST="\033\\"
        ;;
      linux*|xterm*|rxvt*)
        ESCAPE_CODE_DCS="\033]0;"
        ESCAPE_CODE_ST="\007"
        ;;
      *)
        ;;
    esac
    # in a screen
    [ -n "${STY}" ] \
     && export PROMPT_COMMAND='printf "${ESCAPE_CODE_DCS:-\033]0;}%s${ESCAPE_CODE_ST:-\007}" "${PWD##*/}"' \
     || export PROMPT_COMMAND='printf "${ESCAPE_CODE_DCS:-\033]0;}%s@%s:%s${ESCAPE_CODE_ST:-\007}" "${USER}" "${HOSTNAME%%.*}" "${PWD##*/}"'
}
