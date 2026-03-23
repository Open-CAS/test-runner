#!/bin/bash
#
# Copyright(c) 2026 Unvertical
# SPDX-License-Identifier: BSD-3-Clause
#

_jogger() {
    local cur prev command
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    local commands="init tests run rerun delete queue status summary results show log html-log html-logs stdout"

    # Determine the subcommand
    command=""
    for ((i=1; i < COMP_CWORD; i++)); do
        case "${COMP_WORDS[i]}" in
            -*)
                ;;
            *)
                command="${COMP_WORDS[i]}"
                break
                ;;
        esac
    done

    # Complete subcommand name
    if [[ -z "$command" ]]; then
        COMPREPLY=($(compgen -W "$commands" -- "$cur"))
        return
    fi

    # Complete --format value
    if [[ "$prev" == "--format" ]]; then
        COMPREPLY=($(compgen -W "table json" -- "$cur"))
        return
    fi

    # Complete flags per subcommand
    case "$command" in
        init)
            ;;
        tests)
            COMPREPLY=($(compgen -W "--long --collapse --format" -- "$cur"))
            ;;
        run)
            COMPREPLY=($(compgen -W "--failed --not-passed --missing --include-queued --long --format" -- "$cur"))
            ;;
        rerun)
            COMPREPLY=($(compgen -W "--long --format" -- "$cur"))
            ;;
        delete)
            ;;
        queue)
            COMPREPLY=($(compgen -W "--all --long --format" -- "$cur"))
            ;;
        status)
            COMPREPLY=($(compgen -W "--collapse --long --format" -- "$cur"))
            ;;
        summary)
            COMPREPLY=($(compgen -W "--format" -- "$cur"))
            ;;
        results)
            COMPREPLY=($(compgen -W "--last --passed --failed --long --format" -- "$cur"))
            ;;
        show)
            COMPREPLY=($(compgen -W "--format" -- "$cur"))
            ;;
        log)
            ;;
        html-log)
            ;;
        html-logs)
            COMPREPLY=($(compgen -W "--passed --failed" -- "$cur"))
            ;;
        stdout)
            # Complete host names from duts_config.yml
            if [[ -f configs/duts_config.yml ]]; then
                local hosts
                hosts=$(grep -oP '(?<=host:\s")[^"]+' configs/duts_config.yml)
                COMPREPLY=($(compgen -W "$hosts" -- "$cur"))
            fi
            ;;
    esac

    # Filter out already-used flags
    local used_flags=()
    for ((i=2; i < COMP_CWORD; i++)); do
        case "${COMP_WORDS[i]}" in
            -*)
                used_flags+=("${COMP_WORDS[i]}")
                ;;
        esac
    done

    if [[ ${#used_flags[@]} -gt 0 ]]; then
        local filtered=()
        for reply in "${COMPREPLY[@]}"; do
            local already_used=false
            for used in "${used_flags[@]}"; do
                if [[ "$reply" == "$used" ]]; then
                    already_used=true
                    break
                fi
            done
            if ! $already_used; then
                filtered+=("$reply")
            fi
        done
        COMPREPLY=("${filtered[@]}")
    fi
}

complete -F _jogger jogger
