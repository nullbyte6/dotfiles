#!/usr/bin/env bash

mapfile -t repos < <(find "$HOME" -maxdepth 3 \( -name '.*' ! -name '.git' ! -path "$HOME" -o -name node_modules \) -prune -o -name .git -print 2>/dev/null | sed 's|/\.git$||' | sort)

dirty=()
for repo in "${repos[@]}"; do
    count=$(git -C "$repo" status --porcelain 2>/dev/null | wc -l)
    ahead=$(git -C "$repo" rev-list --count '@{u}..HEAD' 2>/dev/null || echo 0)
    if [ "$count" -gt 0 ] || [ "$ahead" -gt 0 ]; then
        dirty+=("$repo")
        printf '%2d) %s: %d changes, %d unpushed\n' "${#dirty[@]}" "${repo/#$HOME/~}" "$count" "$ahead"
    fi
done

if [ "${#dirty[@]}" -eq 0 ]; then
    echo "All ${#repos[@]} repos are clean and pushed"
    exit 0
fi

echo
read -rp "Push which? (numbers separated by space, 'a' for all, Enter to quit): " answer

targets=()
if [ "$answer" = "a" ]; then
    targets=("${dirty[@]}")
else
    for n in $answer; do
        if [[ "$n" =~ ^[0-9]+$ ]] && [ "$n" -ge 1 ] && [ "$n" -le "${#dirty[@]}" ]; then
            targets+=("${dirty[$((n - 1))]}")
        fi
    done
fi

for repo in "${targets[@]}"; do
    echo "Pushing ${repo/#$HOME/~}"
    git -C "$repo" push
done
