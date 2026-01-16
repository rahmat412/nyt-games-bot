# NYT Games Bot - User Guide

A Discord bot that tracks Wordle, Connections, Strands, and Pips scores for your Discord server.

## Table of Contents

- [Quick Start](#quick-start)
- [How It Works](#how-it-works)
- [Commands](#commands)
  - [?ranks](#ranks---view-leaderboard)
  - [?stats](#stats---view-statistics)
  - [?entries](#entries---view-submitted-entries)
  - [?missing](#missing---show-missing-players)
  - [?view](#view---view-specific-puzzle)
  - [?help](#help---get-help)
- [Admin Commands](#admin-commands)
  - [?add](#add---manually-add-entry)
  - [?remove](#remove---remove-entry)
- [Supported Games](#supported-games)
- [Tips & Tricks](#tips--tricks)

---

## Quick Start

1. **Post your game results** in a channel with the game name (e.g., `#wordle`, `#connections`)
2. The bot will automatically record your score and react with a checkmark
3. Use `?ranks` to see the leaderboard
4. Use `?stats` to see your statistics

---

## How It Works

### Automatic Entry Recording

Simply paste your game results into a channel that contains the game name. The bot will:
- Automatically detect the game type from the channel name
- Parse your score from the game output
- Save it to the database
- React with ✅ if successful, or ❌ if there's an error

**Example:** Post in `#wordle`:
```
Wordle 1,234 4/6

⬜🟨⬜⬜⬜
⬜⬜🟩⬜🟨
🟨🟩🟩⬜⬜
🟩🟩🟩🟩🟩
```

### Game Detection

The bot detects which game you're playing based on:
1. **Channel name** - If the channel contains "wordle", "connections", "strands", or "pips"
2. **Command prefix** - Specify the game as the first argument if not in a game channel

---

## Commands

All commands use the `?` prefix.

### ?ranks - View Leaderboard

View the ranked leaderboard for players.

**Usage:**
```
?ranks                      # Weekly rankings (default)
?ranks today                # Today's puzzle only
?ranks weekly               # This week's puzzles
?ranks month                # This month's puzzles
?ranks 10-day               # Last 10 days average
?ranks all-time             # All-time rankings
?ranks 42                   # Rankings for puzzle #42
?ranks 01/12/2025           # Week starting on that Sunday
```

**Time Period Options:**
| Period | Aliases | Description |
|--------|---------|-------------|
| `today` | - | Today's puzzle only |
| `weekly` | `week` | Current week (default) |
| `month` | `monthly` | Current month |
| `10-day` | `10day` | Last 10 days rolling average |
| `all-time` | `alltime` | All recorded puzzles |

**Examples:**
```
?ranks today
?ranks all-time
?ranks wordle today         # Specify game if not in game channel
```

---

### ?stats - View Statistics

View detailed game statistics for one or more players.

**Usage:**
```
?stats                      # Your statistics
?stats @player              # Specific player's stats
?stats @player1 @player2    # Compare multiple players
```

**Examples:**
```
?stats
?stats @john
?stats @john @jane @bob
?stats connections @player  # Specify game if needed
```

---

### ?entries - View Submitted Entries

View a chronological list of all submitted entries.

**Usage:**
```
?entries                    # Your entries
?entries @player            # Specific player's entries
```

**Examples:**
```
?entries
?entries @john
?entries wordle @john       # Specify game if needed
```

---

### ?missing - Show Missing Players

View and mention players who haven't submitted a specific puzzle.

**Usage:**
```
?missing                    # Today's puzzle
?missing 42                 # Specific puzzle number
?missing #42                # Also works with # prefix
```

**Examples:**
```
?missing
?missing 1234
?missing strands            # Specify game if needed
```

---

### ?view - View Specific Puzzle

View detailed information about specific puzzle entries.

**Usage:**
```
?view 42                    # Your entry for puzzle #42
?view @player 42            # Player's entry for puzzle #42
?view @player 40 41 42      # Multiple puzzles
```

**Examples:**
```
?view 1234
?view @john 1234
?view @jane 1230 1231 1232 1233 1234
```

---

### ?help - Get Help

Display help information for commands.

**Usage:**
```
?help                       # Show all commands
?help ranks                 # Help for specific command
```

---

## Admin Commands

These commands are restricted to server administrators.

### ?add - Manually Add Entry

Manually add a game entry to the database.

**Usage:**
```
?add <game output>          # Add to your account
?add @player <game output>  # Add to another player's account
```

**Examples:**
```
?add Wordle 1,234 4/6
⬜🟨⬜⬜⬜
🟩🟩🟩🟩🟩

?add @john Wordle 1,234 3/6
⬜⬜🟨⬜⬜
🟨🟩🟩⬜⬜
🟩🟩🟩🟩🟩
```

---

### ?remove - Remove Entry

Remove a previously recorded entry from the database.

**Usage:**
```
?remove 42                  # Remove your puzzle #42 entry
?remove @player 42          # Remove another player's entry
```

**Examples:**
```
?remove 1234
?remove @john 1234
?remove wordle @john 1234   # Specify game if needed
```

---

## Supported Games

### Wordle

Daily word guessing game. Score is based on number of attempts (1-6, or X for failure).

**Format:**
```
Wordle 1,234 4/6

⬜🟨⬜⬜⬜
⬜⬜🟩⬜🟨
🟨🟩🟩⬜⬜
🟩🟩🟩🟩🟩
```

---

### Connections

Daily word grouping puzzle. Score is based on mistakes made (0-4).

**Format:**
```
Connections
Puzzle #123
🟨🟨🟨🟨
🟩🟩🟩🟩
🟦🟦🟦🟦
🟪🟪🟪🟪
```

---

### Strands

Daily themed word search puzzle. Score includes hints used and spangram bonus.

**Format:**
```
Strands #123
"Theme Title"
💡🔵🔵
🔵🔵🔵
🟡🔵
```

---

### Pips

Daily card game puzzle. Score is based on cards remaining.

**Format:**
```
Pips #123
🃏 12/24
```

---

## Tips & Tricks

### Using Commands Outside Game Channels

If you're not in a game-specific channel, prefix your command with the game name:

```
?ranks wordle today
?stats connections @player
?missing strands
?entries pips
```

### Date Format for Weekly Rankings

When using a date for weekly rankings, the date must be a Sunday (start of the week):

```
?ranks 01/12/2025           # Must be a Sunday
```

### Comparing Multiple Players

Use the `?stats` command with multiple mentions to compare players side-by-side:

```
?stats @player1 @player2 @player3
```

### Viewing Multiple Puzzles

Use the `?view` command with multiple puzzle numbers:

```
?view @player 100 101 102 103 104
```

---

## Troubleshooting

### Bot didn't record my entry

- Make sure you're posting in a channel with the game name
- Verify your game output is in the correct format (copy directly from the game)
- Check if the bot reacted with ❌ (indicates a parsing error)

### Command not working

- Verify you're using the `?` prefix
- If not in a game channel, specify the game name after the command
- Use `?help <command>` for usage information

### Entry already exists

- Each player can only have one entry per puzzle
- Use `?remove` (admin only) to delete an incorrect entry before re-adding

---

## Need Help?

- Use `?help` to see all available commands
- Use `?help <command>` for detailed help on a specific command
- Report issues at: https://github.com/rahmat412/nyt-games-bot/issues
