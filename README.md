# claude_statusline

A Gleam-based status line formatter for Claude Code that displays session information in a rich, informative format.

## What it does

`claude_statusline` reads JSON input from stdin containing Claude Code session metadata and outputs a formatted status line showing:

- 🤖 **Model**: The Claude model being used (e.g., "Sonnet 4.5")
- 🧠 **Context**: Percentage of context window used and total context window size
- 🔥 **Token Usage**: Input and output tokens (current/total) with smart formatting (k for thousands, M for millions)
- 💸 **Cost**: Total USD cost of the session (formatted to 3 decimal places)

### Example Output

```
🤖 Claude Sonnet 4.5 | 🧠 45% (200k) | 🔥  25.3k/150k  8.7k/50k | 💸 $0.123
```

Note: The fire icon (🔥) is followed by special Nerd Font icons ( and ) for input and output tokens respectively.

## Usage

This tool is designed to be used as a hook in Claude Code's configuration. It reads JSON from stdin and prints a formatted status line.

```sh
gleam run < session.json
```

The input JSON should contain the following structure:

````json
{
  "cwd": "/current/working/directory",
  "session_id": "abc123...",
  "transcript_path": "/path/to/transcript.jsonl",
  "model": {
    "id": "claude-opus-4-6",
    "display_name": "Opus"
  },
  "workspace": {
    "current_dir": "/current/working/directory",
    "project_dir": "/original/project/directory"
  },
  "version": "1.0.80",
  "output_style": {
    "name": "default"
  },
  "cost": {
    "total_cost_usd": 0.01234,
    "total_duration_ms": 45000,
    "total_api_duration_ms": 2300,
    "total_lines_added": 156,
    "total_lines_removed": 23
  },
  "context_window": {
    "total_input_tokens": 15234,
    "total_output_tokens": 4521,
    "context_window_size": 200000,
    "used_percentage": 8,
    "remaining_percentage": 92,
    "current_usage": {
      "input_tokens": 8500,
      "output_tokens": 1200,
      "cache_creation_input_tokens": 5000,
      "cache_read_input_tokens": 2000
    }
  },
  "exceeds_200k_tokens": false,
  "vim": {
    "mode": "NORMAL"
  },
  "agent": {
    "name": "security-reviewer"
  }
}
```

### Features

- **Smart Token Formatting**: Automatically formats large numbers with k (thousands) or M (millions) suffix
  - `1500` → `1.5k`
  - `2500000` → `2.5M`
- **Cost Precision**: Shows cost rounded to 3 decimal places (e.g., `$0.123`)
- **Error Handling**: Gracefully handles missing fields with sensible defaults
- **Flexible Parsing**: Accepts both integer and float values for percentage fields

## Development

```sh
gleam run   # Run the project
gleam test  # Run the tests
````

## Deploy

```
./deploy.sh
```
