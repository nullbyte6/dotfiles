#!/usr/bin/env bash

repos=()
chg=()
ahead=()
up=()
err=()
marked=()
view=()
cursor=0
top=0
show_clean=1
status_msg=""
KEY=""
home_tag="~"

cleanup() {
    printf '\e[?25h\e[?1049l'
    stty echo 2>/dev/null
}

trap cleanup EXIT
trap 'exit 130' INT TERM

short() {
    printf '%s' "${1/#$HOME/$home_tag}"
}

pending() {
    ((chg[$1] > 0 || ahead[$1] > 0 || err[$1] > 0))
}

check_repo() {
    local i=$1 r=${repos[$1]} out
    err[i]=0
    chg[i]=0
    ahead[i]=0
    up[i]=0
    if ! out=$(git --no-optional-locks -C "$r" status --porcelain 2>/dev/null); then
        err[i]=1
        return
    fi
    if [ -n "$out" ]; then
        chg[i]=$(printf '%s\n' "$out" | wc -l)
        chg[i]=$((chg[i]))
    fi
    if git -C "$r" rev-parse --abbrev-ref '@{u}' >/dev/null 2>&1; then
        up[i]=1
        ahead[i]=$(git -C "$r" rev-list --count '@{u}..HEAD' 2>/dev/null || echo 0)
    fi
}

scan() {
    local i total
    printf '\e[H\e[2J\e[?25l'
    printf 'Scanning the whole machine for git repos...\n'
    mapfile -t repos < <(find / -maxdepth 10 \( -path /proc -o -path /sys -o -path /dev -o -path /run/user -o -path /usr -o -path /var -o -path /boot -o -path /tmp -o -path /snap -o -name node_modules -o -name .cache -o -name .cargo -o -name .npm -o -name .rustup -o -name Trash -o -name .steam \) -prune -o -name .git -prune -print 2>/dev/null | sed 's|/\.git$||' | sort -u)
    total=${#repos[@]}
    chg=()
    ahead=()
    up=()
    err=()
    marked=()
    for ((i = 0; i < total; i++)); do
        printf '\rChecking repos %d/%d' "$((i + 1))" "$total"
        check_repo "$i"
    done
    cursor=0
    top=0
}

build_view() {
    local i n
    view=()
    for i in "${!repos[@]}"; do
        pending "$i" && view+=("$i")
    done
    if [ "$show_clean" = 1 ]; then
        for i in "${!repos[@]}"; do
            pending "$i" || view+=("$i")
        done
    fi
    n=${#view[@]}
    if ((cursor >= n)); then
        cursor=$((n > 0 ? n - 1 : 0))
    fi
}

readkey() {
    local k s
    IFS= read -rsn1 k || {
        KEY=q
        return
    }
    if [ "$k" = $'\e' ]; then
        if IFS= read -rsn2 -t 0.05 s; then
            case "$s" in
                '[A') KEY=up ;;
                '[B') KEY=down ;;
                '[C') KEY=right ;;
                '[D') KEY=left ;;
                '[5') IFS= read -rsn1 -t 0.05 _; KEY=pgup ;;
                '[6') IFS= read -rsn1 -t 0.05 _; KEY=pgdn ;;
                *) KEY=other ;;
            esac
        else
            KEY=esc
        fi
    elif [ -z "$k" ]; then
        KEY=enter
    elif [ "$k" = " " ]; then
        KEY=space
    else
        KEY=$k
    fi
}

draw() {
    local cols rows page n i idx row mark ptr p w info ahead_s pend=0 mk=0 filter buf line help
    cols=$(tput cols)
    rows=$(tput lines)
    page=$((rows - 4))
    ((page < 1)) && page=1
    n=${#view[@]}
    ((cursor < top)) && top=$cursor
    ((cursor >= top + page)) && top=$((cursor - page + 1))
    for i in "${!repos[@]}"; do
        pending "$i" && ((pend++))
        [ -n "${marked[$i]}" ] && ((mk++))
    done
    filter="all repos"
    [ "$show_clean" = 1 ] || filter="pending only"
    w=$((cols - 30))
    ((w < 10)) && w=10
    buf=$'\e[H'
    buf+=$'\e[1momnis\e[0m'"  ${#repos[@]} repos | $pend pending | $mk marked | showing $filter"$'\e[K\n\e[K\n'
    for ((row = 0; row < page; row++)); do
        idx=$((top + row))
        if ((idx < n)); then
            i=${view[idx]}
            mark="[ ]"
            [ -n "${marked[$i]}" ] && mark="[x]"
            ptr=" "
            ((idx == cursor)) && ptr=">"
            p=$(short "${repos[$i]}")
            if ((${#p} > w)); then
                p="…${p: -$((w - 1))}"
            fi
            if ((err[i])); then
                info=$(printf '%-22s' 'error reading repo')
            else
                ahead_s=${ahead[$i]}
                ((up[i])) || ahead_s="n/a"
                info=$(printf '%4d chg %4s unpushed' "${chg[$i]}" "$ahead_s")
            fi
            line=$(printf '%s %s %-*s  %s' "$ptr" "$mark" "$w" "$p" "$info")
            line=${line:0:cols}
            if ((idx == cursor)); then
                buf+=$'\e[7m'"$line"$'\e[0m\e[K\n'
            elif pending "$i"; then
                buf+=$'\e[33m'"$line"$'\e[0m\e[K\n'
            else
                buf+=$'\e[2m'"$line"$'\e[0m\e[K\n'
            fi
        else
            buf+=$'\e[K\n'
        fi
    done
    buf+=$'\e[K\n'
    buf+=$'\e[1m'"${status_msg:0:cols}"$'\e[0m\e[K\n'
    help="j/k move  space mark  a mark all  enter details  p push  P push all  f filter  r rescan  q quit"
    buf+="${help:0:cols}"$'\e[K\e[J'
    printf '%s' "$buf"
}

detail() {
    local i=$1 r=${repos[$1]} out l x y p branch rows cols page max n k s=0 color txt buf
    local added=() changed=() deleted=() commits=() lines=()
    out=$(git --no-optional-locks -C "$r" status --porcelain -uall 2>/dev/null)
    while IFS= read -r l; do
        [ -z "$l" ] && continue
        x=${l:0:1}
        y=${l:1:1}
        p=${l:3}
        if [ "$x" = D ] || [ "$y" = D ]; then
            deleted+=("$p")
        elif [ "${l:0:2}" = "??" ] || [ "$x" = A ] || [ "$y" = A ]; then
            added+=("$p")
        else
            changed+=("$p")
        fi
    done <<<"$out"
    branch=$(git -C "$r" rev-parse --abbrev-ref HEAD 2>/dev/null)
    if ((up[i])); then
        mapfile -t commits < <(git -C "$r" log --oneline '@{u}..HEAD' 2>/dev/null)
    fi
    lines=("T:$(short "$r")  [$branch]" "N:")
    lines+=("H:Added (${#added[@]})")
    for p in "${added[@]}"; do lines+=("A:  + $p"); done
    lines+=("N:" "H:Changed (${#changed[@]})")
    for p in "${changed[@]}"; do lines+=("C:  ~ $p"); done
    lines+=("N:" "H:Deleted (${#deleted[@]})")
    for p in "${deleted[@]}"; do lines+=("D:  - $p"); done
    lines+=("N:")
    if ((up[i])); then
        lines+=("H:Unpushed commits (${#commits[@]})")
        for p in "${commits[@]}"; do lines+=("N:  $p"); done
    else
        lines+=("H:Unpushed commits: no upstream branch")
    fi
    n=${#lines[@]}
    while :; do
        rows=$(tput lines)
        cols=$(tput cols)
        page=$((rows - 1))
        ((page < 1)) && page=1
        max=$((n - page))
        ((max < 0)) && max=0
        ((s > max)) && s=$max
        buf=$'\e[H'
        for ((k = 0; k < page; k++)); do
            if ((s + k < n)); then
                l=${lines[s + k]}
                txt=${l:2}
                txt=${txt:0:cols}
                case "${l:0:1}" in
                    T) color="1" ;;
                    H) color="1;36" ;;
                    A) color="32" ;;
                    C) color="33" ;;
                    D) color="31" ;;
                    *) color="0" ;;
                esac
                buf+=$'\e['"${color}m${txt}"$'\e[0m\e[K\n'
            else
                buf+=$'\e[K\n'
            fi
        done
        buf+="up/down/PgUp/PgDn scroll  p push  q back"$'\e[K\e[J'
        printf '%s' "$buf"
        readkey
        case "$KEY" in
            up | k) ((s > 0)) && ((s--)) ;;
            down | j) ((s < max)) && ((s++)) ;;
            pgup) s=$((s - page)); ((s < 0)) && s=0 ;;
            pgdn) s=$((s + page)); ((s > max)) && s=$max ;;
            g) s=0 ;;
            G) s=$max ;;
            p)
                push_flow "$i"
                return
                ;;
            q | esc | left | enter) return ;;
        esac
    done
}

push_flow() {
    local i r ok=0 fail=0 skip=0 total=0 a
    local targets=() skipped=()
    for i in "$@"; do
        if ((up[i] && ahead[i] > 0)); then
            targets+=("$i")
            total=$((total + ahead[i]))
        else
            skipped+=("$i")
        fi
    done
    printf '\e[?25h\e[H\e[2J'
    if [ "${#targets[@]}" -eq 0 ]; then
        printf 'Nothing to push: no selected repo has unpushed commits on an upstream branch.\n\nPress any key...'
        read -rsn1
        printf '\e[?25l'
        return
    fi
    printf '\e[1mPush plan\e[0m\n\n'
    for i in "${targets[@]}"; do
        printf '  %-*s  %d commit(s)\n' "$(($(tput cols) - 20))" "$(short "${repos[$i]}")" "${ahead[$i]}"
    done
    if [ "${#skipped[@]}" -gt 0 ]; then
        printf '\nSkipped (nothing to push or no upstream): %d\n' "${#skipped[@]}"
    fi
    printf '\nPush %d repo(s), %d commit(s)? [y/N] ' "${#targets[@]}" "$total"
    read -rsn1 a
    printf '\n\n'
    if [ "$a" != y ] && [ "$a" != Y ]; then
        status_msg="Push cancelled"
        printf '\e[?25l'
        return
    fi
    for i in "${targets[@]}"; do
        r=${repos[$i]}
        printf '\e[1m==> %s\e[0m\n' "$(short "$r")"
        if git -C "$r" push; then
            ((ok++))
        else
            ((fail++))
        fi
        check_repo "$i"
        unset 'marked[i]'
    done
    skip=${#skipped[@]}
    status_msg="Pushed $ok, failed $fail, skipped $skip"
    printf '\n%s. Press any key...' "$status_msg"
    read -rsn1
    printf '\e[?25l'
}

push_marked_or_current() {
    local i targets=()
    for i in "${!repos[@]}"; do
        [ -n "${marked[$i]}" ] && targets+=("$i")
    done
    if [ "${#targets[@]}" -eq 0 ] && [ "${#view[@]}" -gt 0 ]; then
        targets=("${view[$cursor]}")
    fi
    push_flow "${targets[@]}"
}

push_all() {
    local i targets=()
    for i in "${!repos[@]}"; do
        ((up[i] && ahead[i] > 0)) && targets+=("$i")
    done
    push_flow "${targets[@]}"
}

toggle_all() {
    local i all=1
    for i in "${view[@]}"; do
        [ -z "${marked[$i]}" ] && all=0
    done
    for i in "${view[@]}"; do
        if [ "$all" = 1 ]; then
            unset 'marked[i]'
        else
            marked[i]=1
        fi
    done
}

main() {
    local n page idx
    if [ ! -t 0 ] || [ ! -t 1 ]; then
        echo "omnis.sh needs an interactive terminal" >&2
        exit 1
    fi
    command -v git >/dev/null || {
        echo "git is not installed" >&2
        exit 1
    }
    printf '\e[?1049h\e[?25l'
    scan
    build_view
    while :; do
        draw
        readkey
        n=${#view[@]}
        page=$(($(tput lines) - 4))
        status_msg=""
        case "$KEY" in
            up | k) ((cursor > 0)) && ((cursor--)) ;;
            down | j) ((cursor < n - 1)) && ((cursor++)) ;;
            pgup) cursor=$((cursor - page)); ((cursor < 0)) && cursor=0 ;;
            pgdn) cursor=$((cursor + page)); ((cursor > n - 1)) && cursor=$((n > 0 ? n - 1 : 0)) ;;
            g) cursor=0 ;;
            G) cursor=$((n > 0 ? n - 1 : 0)) ;;
            space)
                if ((n > 0)); then
                    idx=${view[cursor]}
                    if [ -n "${marked[$idx]}" ]; then
                        unset 'marked[idx]'
                    else
                        marked[idx]=1
                    fi
                    ((cursor < n - 1)) && ((cursor++))
                fi
                ;;
            a) toggle_all ;;
            enter | right) ((n > 0)) && detail "${view[cursor]}" ;;
            p) push_marked_or_current ;;
            P) push_all ;;
            f)
                show_clean=$((1 - show_clean))
                cursor=0
                top=0
                ;;
            r) scan ;;
            q) break ;;
        esac
        build_view
    done
}

main
