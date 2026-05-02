#!/usr/bin/env bash
TODO_FILE="$HOME/.todo"
touch "$TODO_FILE"

case "$1" in
  add)
    [ -z "$2" ] && echo "Usage: todo add 'task'" && exit 1
    echo "[ ] $2" >> "$TODO_FILE"
    echo "Added: $2"
    ;;
  done)
    [ -z "$2" ] && echo "Usage: todo done <number>" && exit 1
    sed -i "${2}s/\[ \]/[✓]/" "$TODO_FILE"
    echo "Marked task $2 as done!"
    ;;
  remove)
    [ -z "$2" ] && echo "Usage: todo remove <number>" && exit 1
    sed -i "${2}d" "$TODO_FILE"
    echo "Removed task $2"
    ;;
  clear-done)
    sed -i '/\[✓\]/d' "$TODO_FILE"
    echo "Cleared all completed tasks"
    ;;
  list|"")
    if [ ! -s "$TODO_FILE" ]; then
      echo "✅ No pending tasks!"
    else
      echo ""
      echo "📋 TO-DO LIST"
      echo "─────────────────────────"
      nl -ba "$TODO_FILE"
      echo "─────────────────────────"
      echo ""
    fi
    ;;
  *)
    echo "Commands: add | done | remove | clear-done | list"
    ;;
esac
