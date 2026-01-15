# Portainer Deployment Guide (Synology NAS)

This guide walks you through deploying the NYT Games Discord Bot on a Synology NAS using Portainer.

## Prerequisites

- Synology NAS with Docker/Container Manager installed
- Portainer installed and accessible
- MariaDB or MySQL database server
- Discord Bot Token (from Discord Developer Portal)
- Discord Server (Guild) ID

---

## Part 1: Database Setup

### Option A: Using Synology MariaDB Package

1. Open **Package Center** on your Synology
2. Search for and install **MariaDB 10**
3. During setup, set the root password
4. Open **MariaDB 10** from the main menu and enable TCP/IP connections
5. Note the port (default: 3306)

**MySQL Host Configuration:**

The `docker-compose.yml` includes `extra_hosts` that maps `host.docker.internal` to your NAS IP automatically.

| Setup | Host Value |
|-------|------------|
| Synology MariaDB Package | `host.docker.internal` (recommended - auto-resolves) |
| MariaDB in same Docker stack | `mariadb` (container name) |
| Manual IP | `192.168.x.x` (your NAS IP) |

**Recommended:** Use `host.docker.internal` - it automatically resolves to your Synology's IP address without hardcoding.

### Option B: Using MariaDB in Docker

If you prefer running MariaDB in Docker, you can either:

**Option B1: Add MariaDB to the same stack (Recommended)**

This runs MariaDB alongside the bot in the same Docker network:

```yaml
version: "3.8"

services:
  mariadb:
    image: mariadb:10
    container_name: nyt-mariadb
    restart: unless-stopped
    environment:
      - MYSQL_ROOT_PASSWORD=your_root_password
    volumes:
      - /volume1/docker/nyt-mariadb:/var/lib/mysql

  nyt-games-bot:
    image: ghcr.io/rahmat412/nyt-games-bot:latest
    container_name: nyt-games-bot
    restart: unless-stopped
    depends_on:
      - mariadb
    environment:
      - DISCORD_TOKEN=${DISCORD_TOKEN}
      - GUILD_ID=${GUILD_ID}
      # Use container name as host when in same stack
      - WORDLE_MYSQL_HOST=mariadb
      - WORDLE_MYSQL_USER=nyt_bot
      - WORDLE_MYSQL_PASS=${MYSQL_PASSWORD}
      - WORDLE_MYSQL_DB_NAME=nyt_wordle
      # ... repeat for other games
```

When MariaDB is in the same stack, use the container name (`mariadb`) as the host.

**Option B2: Run MariaDB in a separate stack**

```yaml
services:
  mariadb:
    image: mariadb:10
    container_name: nyt-mariadb
    restart: unless-stopped
    environment:
      - MYSQL_ROOT_PASSWORD=your_root_password
    volumes:
      - /volume1/docker/mariadb:/var/lib/mysql
    ports:
      - "3306:3306"
```

When MariaDB is in a separate stack, use your NAS IP (e.g., `192.168.1.100`) as the host.

### Option C: All-in-One Stack with MariaDB (Easiest)

Use `docker-compose.full.yml` for a complete self-contained setup:

1. In Portainer: **Stacks** → **Add stack**
2. Choose **Repository**:
   - Repository URL: `https://github.com/rahmat412/nyt-games-bot`
   - Compose path: `docker-compose.full.yml`
3. Add these environment variables:

| Variable | Value |
|----------|-------|
| `DISCORD_TOKEN` | Your bot token |
| `GUILD_ID` | Your server ID |
| `MYSQL_ROOT_PASSWORD` | Root password for MariaDB |
| `MYSQL_PASSWORD` | Password for nyt_bot user |

The init script runs automatically on first start and creates all databases/tables.

### Create the Databases

1. Connect to your MariaDB using a MySQL client (e.g., DBeaver, phpMyAdmin, or command line)

2. Run the init script `scripts/init.sql` which creates databases, user, and tables:

**Option A: Command line**
```bash
mysql -u root -p < scripts/init.sql
```

**Option B: Copy and paste into phpMyAdmin or DBeaver**

See full script at [scripts/init.sql](../scripts/init.sql)

**Important:** Edit the script first and change `'your_secure_password'` to your actual password:
```sql
CREATE USER IF NOT EXISTS 'nyt_bot'@'%' IDENTIFIED BY 'your_secure_password';
```

---

## Part 2: Get Discord Credentials

### Create a Discord Bot

1. Go to [Discord Developer Portal](https://discord.com/developers/applications)
2. Click **New Application** and give it a name
3. Go to **Bot** section in the left sidebar
4. Click **Reset Token** and copy your bot token (save this securely)
5. **IMPORTANT:** Enable ALL **Privileged Gateway Intents**:
   - ✅ **Presence Intent** - Required
   - ✅ **Server Members Intent** - Required
   - ✅ **Message Content Intent** - Required
6. Click **Save Changes**

> ⚠️ **If you skip step 5**, you will get this error:
> `discord.errors.PrivilegedIntentsRequired: Shard ID None is requesting privileged intents that have not been explicitly enabled`

### Invite Bot to Your Server

1. Go to **OAuth2** → **URL Generator**
2. Select scopes: `bot`, `applications.commands`
3. Select bot permissions: `Send Messages`, `Read Message History`, `Add Reactions`, `Attach Files`
4. Copy the generated URL and open it in your browser
5. Select your server and authorize

### Get Your Server ID

1. In Discord, go to **User Settings** → **Advanced** → Enable **Developer Mode**
2. Right-click your server name → **Copy Server ID**

---

## Part 3: Deploy with Portainer

### Method 1: Deploy from Git Repository (Recommended)

1. Open Portainer web interface
2. Navigate to **Stacks** in the left sidebar
3. Click **+ Add stack**
4. Configure the stack:
   - **Name:** `nyt-games-bot`
   - **Build method:** Select **Repository**
   - **Repository URL:** `https://github.com/rahmat412/nyt-games-bot`
   - **Repository reference:** `refs/heads/main`
   - **Compose path:** `docker-compose.yml`

5. Scroll down to **Environment variables**
6. Click **+ Add an environment variable** for each of the following:

| Name | Value |
|------|-------|
| `DISCORD_TOKEN` | Your bot token from Part 2 |
| `GUILD_ID` | Your server ID from Part 2 |
| `WORDLE_MYSQL_HOST` | Your Synology NAS IP (e.g., `192.168.1.100`) |
| `WORDLE_MYSQL_USER` | `nyt_bot` |
| `WORDLE_MYSQL_PASS` | Password you set in Part 1 |
| `WORDLE_MYSQL_DB_NAME` | `nyt_wordle` |
| `CONNECTIONS_MYSQL_HOST` | Your Synology NAS IP |
| `CONNECTIONS_MYSQL_USER` | `nyt_bot` |
| `CONNECTIONS_MYSQL_PASS` | Your password |
| `CONNECTIONS_MYSQL_DB_NAME` | `nyt_connections` |
| `STRANDS_MYSQL_HOST` | Your Synology NAS IP |
| `STRANDS_MYSQL_USER` | `nyt_bot` |
| `STRANDS_MYSQL_PASS` | Your password |
| `STRANDS_MYSQL_DB_NAME` | `nyt_strands` |
| `PIPS_MYSQL_HOST` | Your Synology NAS IP |
| `PIPS_MYSQL_USER` | `nyt_bot` |
| `PIPS_MYSQL_PASS` | Your password |
| `PIPS_MYSQL_DB_NAME` | `nyt_pips` |

7. Click **Deploy the stack**

### Method 2: Deploy with Web Editor

1. Open Portainer → **Stacks** → **+ Add stack**
2. **Name:** `nyt-games-bot`
3. **Build method:** Select **Web editor**
4. Paste this docker-compose configuration:

```yaml
version: "3.8"

services:
  nyt-games-bot:
    image: ghcr.io/rahmat412/nyt-games-bot:latest
    container_name: nyt-games-bot
    restart: unless-stopped
    environment:
      - DISCORD_TOKEN=${DISCORD_TOKEN}
      - GUILD_ID=${GUILD_ID}
      - WORDLE_MYSQL_HOST=${WORDLE_MYSQL_HOST}
      - WORDLE_MYSQL_USER=${WORDLE_MYSQL_USER}
      - WORDLE_MYSQL_PASS=${WORDLE_MYSQL_PASS}
      - WORDLE_MYSQL_DB_NAME=${WORDLE_MYSQL_DB_NAME:-nyt_wordle}
      - CONNECTIONS_MYSQL_HOST=${CONNECTIONS_MYSQL_HOST}
      - CONNECTIONS_MYSQL_USER=${CONNECTIONS_MYSQL_USER}
      - CONNECTIONS_MYSQL_PASS=${CONNECTIONS_MYSQL_PASS}
      - CONNECTIONS_MYSQL_DB_NAME=${CONNECTIONS_MYSQL_DB_NAME:-nyt_connections}
      - STRANDS_MYSQL_HOST=${STRANDS_MYSQL_HOST}
      - STRANDS_MYSQL_USER=${STRANDS_MYSQL_USER}
      - STRANDS_MYSQL_PASS=${STRANDS_MYSQL_PASS}
      - STRANDS_MYSQL_DB_NAME=${STRANDS_MYSQL_DB_NAME:-nyt_strands}
      - PIPS_MYSQL_HOST=${PIPS_MYSQL_HOST}
      - PIPS_MYSQL_USER=${PIPS_MYSQL_USER}
      - PIPS_MYSQL_PASS=${PIPS_MYSQL_PASS}
      - PIPS_MYSQL_DB_NAME=${PIPS_MYSQL_DB_NAME:-nyt_pips}
      - CONFIRM_ENTRIES=${CONFIRM_ENTRIES:-True}

  # Optional: Auto-update when new images are pushed
  watchtower:
    image: containrrr/watchtower
    container_name: watchtower-nyt-bot
    restart: unless-stopped
    environment:
      - WATCHTOWER_CLEANUP=true
      - WATCHTOWER_POLL_INTERVAL=300
      - WATCHTOWER_SCOPE=nyt-games-bot
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    command: nyt-games-bot
```

5. Add environment variables as shown in Method 1
6. Click **Deploy the stack**

---

## Part 4: Verify Deployment

### Check Container Status

1. In Portainer, go to **Containers**
2. Find `nyt-games-bot` - it should show **running** status
3. Click on the container name to view details

### Check Logs

1. Click on `nyt-games-bot` container
2. Click **Logs** in the top menu
3. You should see: `Database loaded & successfully logged in.`

If you see errors:
- **Connection refused**: Check MySQL host IP and ensure MariaDB is running
- **Access denied**: Verify MySQL username and password
- **Unknown database**: Ensure you ran the setup SQL scripts

### Test the Bot

1. Go to your Discord server
2. Type `?help` - the bot should respond with available commands
3. Paste a Wordle result to test score tracking

---

## Part 5: Auto-Updates (Optional)

The docker-compose includes Watchtower for automatic updates. When you push changes to the `main` branch:

1. GitHub Actions builds a new Docker image
2. Image is pushed to GitHub Container Registry
3. Watchtower detects the new image (checks every 5 minutes)
4. Watchtower automatically pulls and redeploys the container

### Disable Auto-Updates

If you prefer manual updates, remove the `watchtower` service from your stack:

1. Go to **Stacks** → `nyt-games-bot`
2. Click **Editor**
3. Remove or comment out the `watchtower` section
4. Click **Update the stack**

### Manual Update Process

1. Go to **Stacks** → `nyt-games-bot`
2. Click **Pull and redeploy**
3. Check **Re-pull image**
4. Click **Update**

---

## Troubleshooting

### PrivilegedIntentsRequired Error

```
discord.errors.PrivilegedIntentsRequired: Shard ID None is requesting privileged intents...
```

**Fix:** Enable all Privileged Gateway Intents in Discord Developer Portal:
1. Go to [Discord Developer Portal](https://discord.com/developers/applications)
2. Select your application → **Bot**
3. Enable ALL three intents:
   - ✅ Presence Intent
   - ✅ Server Members Intent
   - ✅ Message Content Intent
4. Save and restart the container

### Bot Not Responding

1. Check container logs for errors
2. Verify `DISCORD_TOKEN` is correct
3. Ensure bot has proper permissions in Discord
4. Check that all Privileged Gateway Intents are enabled in Discord Developer Portal

### Database Connection Failed

1. Verify MySQL/MariaDB is running
2. Check the host IP is correct (use your NAS local IP, not `localhost`)
3. Ensure the database user has proper permissions
4. Test connection from another MySQL client first

### Container Keeps Restarting

1. Check logs for the error message
2. Common causes:
   - Invalid Discord token
   - Database connection issues
   - Missing environment variables

### Watchtower Not Updating

1. Verify Watchtower container is running
2. Check Watchtower logs for errors
3. Ensure the image name matches: `ghcr.io/rahmat412/nyt-games-bot`
4. Wait at least 5 minutes for the poll interval

---

## Environment Variables Reference

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `DISCORD_TOKEN` | Yes | - | Bot token from Discord Developer Portal |
| `GUILD_ID` | Yes | - | Discord server ID |
| `WORDLE_MYSQL_HOST` | Yes | - | MySQL server hostname/IP |
| `WORDLE_MYSQL_USER` | Yes | `root` | MySQL username |
| `WORDLE_MYSQL_PASS` | Yes | - | MySQL password |
| `WORDLE_MYSQL_DB_NAME` | No | `nyt_wordle` | Wordle database name |
| `CONNECTIONS_MYSQL_HOST` | Yes | - | MySQL server hostname/IP |
| `CONNECTIONS_MYSQL_USER` | Yes | `root` | MySQL username |
| `CONNECTIONS_MYSQL_PASS` | Yes | - | MySQL password |
| `CONNECTIONS_MYSQL_DB_NAME` | No | `nyt_connections` | Connections database name |
| `STRANDS_MYSQL_HOST` | Yes | - | MySQL server hostname/IP |
| `STRANDS_MYSQL_USER` | Yes | `root` | MySQL username |
| `STRANDS_MYSQL_PASS` | Yes | - | MySQL password |
| `STRANDS_MYSQL_DB_NAME` | No | `nyt_strands` | Strands database name |
| `PIPS_MYSQL_HOST` | Yes | - | MySQL server hostname/IP |
| `PIPS_MYSQL_USER` | Yes | `root` | MySQL username |
| `PIPS_MYSQL_PASS` | Yes | - | MySQL password |
| `PIPS_MYSQL_DB_NAME` | No | `nyt_pips` | Pips database name |
| `CONFIRM_ENTRIES` | No | `True` | React with checkmark when entry recorded |
