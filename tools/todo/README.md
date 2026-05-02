# todo — Terminal Task Manager

A lightweight CLI tool for managing personal to-do items directly from the terminal.
Tasks persist across sessions in `~/.todo` and display automatically on every new terminal open.

## Installation

From the repo root:

```bash
sudo cp tools/todo/todo.sh /usr/local/bin/todo
```

Add auto-display to your `~/.zshrc`:

```bash
# Auto-display todo list on terminal open
if [ -s "$HOME/.todo" ]; then
  todo list
fi
```

## Usage

```bash
todo add "task description"   # Add a new task
todo list                     # List all tasks (default if no command given)
todo done <number>            # Mark task as done
todo remove <number>          # Remove a task permanently
todo clear-done               # Remove all completed tasks
todo help                     # Show help message
```

## Example Session

```
$ todo help

📋 todo — Terminal Task Manager

Usage: todo <command>

Commands:
  add "task"       Add a new task
  list             List all tasks (default)
  done <number>    Mark task as done
  remove <number>  Remove a task permanently
  clear-done       Remove all completed tasks
  help             Show this help message

Examples:
  todo add "Rewrite GitHub Profile README.md"
  todo done 1
  todo remove 2

$ todo add "Rewrite GitHub Profile README.md"
Added: Rewrite GitHub Profile README.md

$ todo add "Set up persistent to-do list system"
Added: Set up persistent to-do list system

$ todo list

📋 TO-DO LIST
─────────────────────────
     1	[ ] Rewrite GitHub Profile README.md
     2	[ ] Set up persistent to-do list system
─────────────────────────

$ todo done 2
Marked task 2 as done!

$ todo clear-done
Cleared all completed tasks

$ todo list

📋 TO-DO LIST
─────────────────────────
     1	[ ] Rewrite GitHub Profile README.md
─────────────────────────
```

## How It Works

- Tasks are stored in `~/.todo` — a plain text file, local only, not versioned
- Each task is prefixed with `[ ]` (pending) or `[✓]` (done)
- `done` and `remove` reference tasks by their line number shown in `todo list`
- The `~/.zshrc` integration prints the list only when tasks exist — no noise on an empty list

## Design Decisions

**Why a plain text file?** Zero dependencies, human-readable, works offline, survives any tool change.

**Why not versioned?** Tasks are personal and ephemeral. The *tool* is versioned here; the *data* stays local.

**Why not a full task manager like Taskwarrior?** This covers the 90% case with zero overhead. If needs grow, migrate later.
