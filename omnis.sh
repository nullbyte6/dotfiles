#!/usr/bin/env bash

repos=()
chg=()
ahead=()
behind=()
up=()
err=()
branch=()
access=()
marked=()
view=()
cursor=0
top=0
show_clean=0
status_msg=""
KEY=""
home_tag="~"
JOBS=8

logo() {
    cat <<'LOGO_EOF'
 ▗▄▖ ▗▖  ▗▖▗▖  ▗▖▗▄▄▄▖ ▗▄▄▖
▐▌ ▐▌▐▛▚▞▜▌▐▛▚▖▐▌  █  ▐▌
▐▌ ▐▌▐▌  ▐▌▐▌ ▝▜▌  █   ▝▀▚▖  v0.1.0
▝▚▄▞▘▐▌  ▐▌▐▌  ▐▌▗▄█▄▖▗▄▄▞▘  by nullbyte6
LOGO_EOF
}

cleanup() {
    printf '\e[?25h\e[?1049l'
    stty echo 2>/dev/null
}

trap cleanup EXIT
trap 'exit 130' INT TERM

short() {
    printf '%s' "${1/#$HOME/$home_tag}"
}

fit() {
    local s=$1 w=$2
    if ((${#s} > w)); then
        s="${s:0:w-1}…"
    fi
    printf '%s%*s' "$s" "$((w - ${#s}))" ""
}

lfit() {
    local s=$1 w=$2
    ((${#s} > w)) && s=${s:0:w}
    printf '%*s%s' "$((w - ${#s}))" "" "$s"
}

pending() {
    ((chg[$1] > 0 || ahead[$1] > 0 || behind[$1] > 0 || err[$1] > 0))
}

sanitize_url() {
    sed -E 's|//[^/@]*@|//|'
}

remote_of() {
    local r=$1 b rm
    b=$(git -C "$r" rev-parse --abbrev-ref HEAD 2>/dev/null)
    rm=$(git -C "$r" config --get "branch.$b.remote" 2>/dev/null)
    [ -z "$rm" ] && rm=$(git -C "$r" remote 2>/dev/null | head -n1)
    printf '%s' "$rm"
}

check_repo() {
    local i=$1 r=${repos[$1]} out counts
    err[i]=0
    chg[i]=0
    ahead[i]=0
    behind[i]=0
    up[i]=0
    branch[i]=$(git -C "$r" rev-parse --abbrev-ref HEAD 2>/dev/null)
    if ! out=$(git --no-optional-locks -C "$r" status --porcelain 2>/dev/null); then
        err[i]=1
        return
    fi
    if [ -n "$out" ]; then
        chg[i]=$(printf '%s\n' "$out" | wc -l)
        chg[i]=$((chg[i]))
    fi
    if counts=$(git -C "$r" rev-list --left-right --count '@{u}...HEAD' 2>/dev/null); then
        up[i]=1
        behind[i]=${counts%%[[:space:]]*}
        ahead[i]=${counts##*[[:space:]]}
    fi
}

probe_access() {
    local i=$1 r=${repos[$1]} remote out rc
    remote=$(remote_of "$r")
    if [ -z "$remote" ]; then
        echo local
        return
    fi
    out=$(GIT_TERMINAL_PROMPT=0 GIT_SSH_COMMAND='ssh -o BatchMode=yes -o ConnectTimeout=8' timeout 20 git -C "$r" push --dry-run "$remote" HEAD 2>&1 </dev/null)
    rc=$?
    if [ "$rc" -eq 0 ]; then
        echo write
    elif grep -qiE 'permission|denied|403|not authorized|authentication failed|could not read (username|password)|access rights|read.only|forbidden' <<<"$out"; then
        echo read
    else
        echo unknown
    fi
}

probe_all() {
    local tmp i k=0 total=$# running=0
    tmp=$(mktemp -d)
    for i in "$@"; do
        printf '\rChecking push access %d/%d' "$((++k))" "$total"
        (probe_access "$i" >"$tmp/$i") &
        ((running++))
        if ((running >= JOBS)); then
            wait -n
            ((running--))
        fi
    done
    wait
    for i in "$@"; do
        access[i]=$(<"$tmp/$i")
    done
    rm -rf "$tmp"
}

probe_missing() {
    local i todo=()
    for i in "${!repos[@]}"; do
        [ -n "${access[$i]}" ] && continue
        if [ "$show_clean" = 1 ] || pending "$i"; then
            todo+=("$i")
        fi
    done
    ((${#todo[@]} > 0)) && probe_all "${todo[@]}"
}

fetch_repos() {
    local i running=0 done_n=0 total=$#
    for i in "$@"; do
        printf '\rFetching %d/%d' "$((++done_n))" "$total"
        (GIT_TERMINAL_PROMPT=0 GIT_SSH_COMMAND='ssh -o BatchMode=yes -o ConnectTimeout=8' timeout 30 git -C "${repos[$i]}" fetch --quiet </dev/null >/dev/null 2>&1) &
        ((running++))
        if ((running >= JOBS)); then
            wait -n
            ((running--))
        fi
    done
    wait
    for i in "$@"; do
        check_repo "$i"
    done
}

scan() {
    local i total
    printf '\e[H\e[2J\e[?25l'
    logo
    printf '\nScanning the whole machine for git repos...\n'
    mapfile -t repos < <(find / -maxdepth 10 \( -path /proc -o -path /sys -o -path /dev -o -path /run/user -o -path /usr -o -path /var -o -path /boot -o -path /tmp -o -path /snap -o -name node_modules -o -name .cache -o -name .cargo -o -name .npm -o -name .rustup -o -name Trash -o -name .steam \) -prune -o -name .git -prune -print 2>/dev/null | sed 's|/\.git$||' | sort -u)
    total=${#repos[@]}
    chg=()
    ahead=()
    behind=()
    up=()
    err=()
    branch=()
    access=()
    marked=()
    for ((i = 0; i < total; i++)); do
        printf '\rChecking repos %d/%d' "$((i + 1))" "$total"
        check_repo "$i"
    done
    printf '\n'
    probe_missing
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

access_label() {
    case "$1" in
        write) printf 'can push' ;;
        read) printf 'read-only' ;;
        local) printf 'local' ;;
        *) printf 'unknown' ;;
    esac
}

access_color() {
    case "$1" in
        write) printf '\e[32m' ;;
        read) printf '\e[31m' ;;
        local) printf '\e[2m' ;;
        *) printf '\e[33m' ;;
    esac
}

draw() {
    local cols rows page n i idx row mark ptr p w line acc buf help filter logo_h=0 summary
    local pend=0 mk=0 canpush=0 chg_s ahead_s behind_s
    cols=$(tput cols)
    rows=$(tput lines)
    ((rows >= 24)) && logo_h=5
    page=$((rows - logo_h - 4))
    ((page < 1)) && page=1
    n=${#view[@]}
    ((cursor < top)) && top=$cursor
    ((cursor >= top + page)) && top=$((cursor - page + 1))
    for i in "${!repos[@]}"; do
        pending "$i" && ((pend++))
        [ -n "${marked[$i]}" ] && ((mk++))
        [ "${access[$i]}" = write ] && ((canpush++))
    done
    filter="all repos"
    [ "$show_clean" = 1 ] || filter="pending only"
    w=$((cols - 47))
    ((w < 10)) && w=10
    buf=$'\e[H'
    if ((logo_h)); then
        while IFS= read -r line; do
            buf+=$'\e[1m'"${line:0:cols}"$'\e[0m\e[K\n'
        done < <(logo)
        buf+=$'\e[K\n'
    fi
    summary="${#repos[@]} repos | $pend pending | $canpush pushable | $mk marked | showing $filter"
    buf+="${summary:0:cols}"$'\e[K\n'
    buf+=$'\e[2;4m'"$(fit '' 6)$(fit 'Repository' "$w")  $(fit 'Branch' 12) $(lfit '±' 5) $(lfit '↑' 4) $(lfit '↓' 4)  $(fit 'Access' 9)"$'\e[0m\e[K\n'
    for ((row = 0; row < page; row++)); do
        idx=$((top + row))
        if ((idx < n)); then
            i=${view[idx]}
            mark="[ ]"
            [ -n "${marked[$i]}" ] && mark="[x]"
            ptr=" "
            ((idx == cursor)) && ptr=">"
            p=$(short "${repos[$i]}")
            chg_s=""
            ahead_s=""
            behind_s=""
            ((chg[i] > 0)) && chg_s="${chg[$i]}"
            if ((up[i])); then
                ((ahead[i] > 0)) && ahead_s="${ahead[$i]}"
                ((behind[i] > 0)) && behind_s="${behind[$i]}"
            else
                ahead_s="-"
                behind_s="-"
            fi
            if ((err[i])); then
                chg_s="err"
            fi
            line="$ptr $mark $(fit "$p" "$w")  $(fit "${branch[$i]}" 12) $(lfit "$chg_s" 5) $(lfit "$ahead_s" 4) $(lfit "$behind_s" 4)  "
            acc=$(fit "$(access_label "${access[$i]}")" 9)
            if ((idx == cursor)); then
                buf+=$'\e[7m'"$line$acc"$'\e[0m\e[K\n'
            elif pending "$i"; then
                buf+="$line$(access_color "${access[$i]}")$acc"$'\e[0m\e[K\n'
            else
                buf+=$'\e[2m'"$line"$'\e[0m'"$(access_color "${access[$i]}")$acc"$'\e[0m\e[K\n'
            fi
        else
            buf+=$'\e[K\n'
        fi
    done
    buf+=$'\e[1m'"${status_msg:0:cols}"$'\e[0m\e[K\n'
    help="j/k move  space mark  a all  enter details  p/P push  l/L pull  F fetch  f filter  r rescan  q quit"
    buf+="${help:0:cols}"$'\e[K\e[J'
    printf '%s' "$buf"
}

detail() {
    local i=$1 r=${repos[$1]} out l x y p rm url rows cols page max n k s=0 color txt buf
    local added=() changed=() deleted=() commits=() incoming=() lines=()
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
    rm=$(remote_of "$r")
    url="-"
    [ -n "$rm" ] && url=$(git -C "$r" remote get-url "$rm" 2>/dev/null | sanitize_url)
    if ((up[i])); then
        mapfile -t commits < <(git -C "$r" log --oneline '@{u}..HEAD' 2>/dev/null)
        mapfile -t incoming < <(git -C "$r" log --oneline 'HEAD..@{u}' 2>/dev/null)
    fi
    lines=("T:$(short "$r")  [${branch[$i]}]" "N:  remote: $url" "N:  access: $(access_label "${access[$i]}")" "N:")
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
        lines+=("N:" "H:Incoming commits (${#incoming[@]})")
        for p in "${incoming[@]}"; do lines+=("N:  $p"); done
    else
        lines+=("H:Commits: no upstream branch")
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
        buf+="up/down/PgUp/PgDn scroll  p push  l pull  q back"$'\e[K\e[J'
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
            l)
                pull_flow "$i"
                return
                ;;
            q | esc | left | enter) return ;;
        esac
    done
}

wait_key() {
    read -rsn1
    printf '\e[?25l'
}

confirm() {
    local a
    read -rsn1 a
    printf '\n\n'
    [ "$a" = y ] || [ "$a" = Y ]
}

push_flow() {
    local i r ok=0 fail=0 total=0
    local targets=() skipped=()
    for i in "$@"; do
        if ((up[i] && ahead[i] > 0)) && [ "${access[$i]}" != read ]; then
            targets+=("$i")
            total=$((total + ahead[i]))
        else
            skipped+=("$i")
        fi
    done
    printf '\e[?25h\e[H\e[2J'
    if [ "${#targets[@]}" -eq 0 ]; then
        printf 'Nothing to push: no selected repo has unpushed commits, an upstream branch and push access.\n\nPress any key...'
        wait_key
        return
    fi
    printf '\e[1mPush plan\e[0m\n\n'
    for i in "${targets[@]}"; do
        printf '  %s  (%d commit(s))\n' "$(short "${repos[$i]}")" "${ahead[$i]}"
    done
    if [ "${#skipped[@]}" -gt 0 ]; then
        printf '\nSkipped (nothing to push, no upstream or read-only): %d\n' "${#skipped[@]}"
    fi
    printf '\nPush %d repo(s), %d commit(s)? [y/N] ' "${#targets[@]}" "$total"
    if ! confirm; then
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
    status_msg="Pushed $ok, failed $fail, skipped ${#skipped[@]}"
    printf '\n%s. Press any key...' "$status_msg"
    wait_key
}

pull_flow() {
    local i r ok=0 fail=0 total=0
    local targets=() skipped=()
    for i in "$@"; do
        if ((up[i] && !err[i])); then
            targets+=("$i")
            total=$((total + behind[i]))
        else
            skipped+=("$i")
        fi
    done
    printf '\e[?25h\e[H\e[2J'
    if [ "${#targets[@]}" -eq 0 ]; then
        printf 'Nothing to pull: no selected repo has an upstream branch.\n\nPress any key...'
        wait_key
        return
    fi
    printf '\e[1mPull plan\e[0m (fast-forward only)\n\n'
    for i in "${targets[@]}"; do
        printf '  %s  (%d incoming commit(s) known)\n' "$(short "${repos[$i]}")" "${behind[$i]}"
    done
    if [ "${#skipped[@]}" -gt 0 ]; then
        printf '\nSkipped (no upstream or unreadable): %d\n' "${#skipped[@]}"
    fi
    printf '\nPull %d repo(s)? [y/N] ' "${#targets[@]}"
    if ! confirm; then
        status_msg="Pull cancelled"
        printf '\e[?25l'
        return
    fi
    for i in "${targets[@]}"; do
        r=${repos[$i]}
        printf '\e[1m==> %s\e[0m\n' "$(short "$r")"
        if git -C "$r" pull --ff-only; then
            ((ok++))
        else
            ((fail++))
        fi
        check_repo "$i"
        unset 'marked[i]'
    done
    status_msg="Pulled $ok, failed $fail, skipped ${#skipped[@]}"
    printf '\n%s. Press any key...' "$status_msg"
    wait_key
}

marked_or_current() {
    local i
    SEL=()
    for i in "${!repos[@]}"; do
        [ -n "${marked[$i]}" ] && SEL+=("$i")
    done
    if [ "${#SEL[@]}" -eq 0 ] && [ "${#view[@]}" -gt 0 ]; then
        SEL=("${view[$cursor]}")
    fi
}

push_all() {
    local i targets=()
    for i in "${!repos[@]}"; do
        ((up[i] && ahead[i] > 0)) && [ "${access[$i]}" != read ] && targets+=("$i")
    done
    push_flow "${targets[@]}"
}

remote_repos() {
    SEL=()
    local i
    for i in "${!repos[@]}"; do
        [ "${access[$i]}" != local ] && ((!err[i])) && SEL+=("$i")
    done
}

fetch_all() {
    remote_repos
    printf '\e[H\e[2J'
    fetch_repos "${SEL[@]}"
    printf '\n'
    probe_missing
    status_msg="Fetched ${#SEL[@]} repos"
}

pull_all() {
    local i targets=()
    fetch_all
    for i in "${SEL[@]}"; do
        ((up[i] && behind[i] > 0)) && targets+=("$i")
    done
    build_view
    pull_flow "${targets[@]}"
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
        page=$(($(tput lines) - 8))
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
            p)
                marked_or_current
                push_flow "${SEL[@]}"
                ;;
            P) push_all ;;
            l)
                marked_or_current
                pull_flow "${SEL[@]}"
                ;;
            L) pull_all ;;
            F) fetch_all ;;
            f)
                show_clean=$((1 - show_clean))
                printf '\e[H\e[2J'
                probe_missing
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
