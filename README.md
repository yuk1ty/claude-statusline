# claude_statusline

A Gleam-based status line formatter for Claude Code that displays session information in a rich, informative format.

## What it does

`claude_statusline` reads JSON input from stdin containing Claude Code session metadata and outputs a formatted status line showing:

- 🤖 **Model**: The Claude model being used (e.g., "Sonnet 4.5")
- 📁 **Folder**: Current working directory name
- 🧠 **Context**: Percentage of context window used
- 💸 **Cost**: Total USD cost of the session

### Example Output

```
🤖 Claude Sonnet 4.5 | 📁 my-project | 🧠 45% context | 💸 $0.12
```

## Usage

This tool is designed to be used as a hook in Claude Code's configuration. It reads JSON from stdin and prints a formatted status line.

```sh
gleam run < session.json
```

The input JSON should contain the following structure:

```json
{
  "model": {
    "display_name": "Claude Sonnet 4.5"
  },
  "workspace": {
    "current_dir": "/path/to/project"
  },
  "context_window": {
    "used_percentage": 45
  },
  "cost": {
    "total_cost_usd": 0.12
  }
}
```

## Development

```sh
gleam run   # Run the project
gleam test  # Run the tests
```

## Deploy

```
./deploy.sh
```
