# How to Use: MediaWiki Docker Compose Setup

This document provides a detailed explanation of each command in the `manage_wiki.sh` script, clarifying their purpose and when to use them.

---

### 1. Normal Daily Operations (Preserves Data)

These commands are for starting, stopping, and managing your running wiki without losing any data or configuration.

*   **`./manage_wiki.sh --run`**
    *   **Purpose:** Starts all MediaWiki services (MariaDB, MediaWiki app, Nginx) in the background.
    *   **When to use:** After initial setup, to start your wiki for daily use.
    *   **Data:** Your wiki's content and configuration (in `./mnt`) are preserved.

*   **`./manage_wiki.sh --stop`**
    *   **Purpose:** Stops all MediaWiki services and removes their containers.
    *   **When to use:** When you're done using the wiki for a while and want to free up resources.
    *   **Data:** Your wiki's content and configuration (in `./mnt`) are preserved.

*   **`./manage_wiki.sh --freeze`**
    *   **Purpose:** Pauses all running services. They remain in memory but consume no CPU.
    *   **When to use:** For very temporary pauses, e.g., if you need to free up CPU instantly for another task.
    *   **Data:** Preserved.

*   **`./manage_wiki.sh --resume`**
    *   **Purpose:** Resumes services from a paused state.
    *   **When to use:** To unpause services after using `--freeze`.
    *   **Data:** Preserved.

*   **`./manage_wiki.sh --shell-app` / `--shell-db` / `--shell-web`**
    *   **Purpose:** Opens a bash shell inside a specific running container for debugging or inspection.
    *   **When to use:** Only when troubleshooting.
    *   **Data:** Preserved.

---

### 2. Cleanup and Installation Operations (May Delete Data)

These commands are for setting up, resetting, or completely removing the MediaWiki project.

*   **`./manage_wiki.sh --destroy`**
    *   **Purpose:** To perform a **complete, aggressive cleanup of the Docker environment and all persistent data** for *this specific project*. This is the "reset to factory settings" button for your wiki.
    *   **Action:**
        1.  Forcefully stops and removes all containers.
        2.  Removes all associated Docker networks and named volumes.
        3.  **Crucially:** It then uses `sudo rm -rf` to **permanently delete the contents of your `./mnt` directory** (database files, images, `LocalSettings.php`).
    *   **When to use:**
        *   When you want to reinstall the MediaWiki project from scratch (e.g., for a new user, or if you're debugging a persistent issue that requires a fresh database).
        *   If you've made changes to `docker-compose.yml` that require a full rebuild and data wipe.
    *   **Result:** Your Docker environment is clean, and your `./mnt` directory is empty. Your project files (`manage_wiki.sh`, `docker-compose.yml`, etc.) remain.
    *   **Important:** This command will prompt you for your `sudo` password.

*   **`./manage_wiki.sh --update`**
    *   **Purpose:** Runs MediaWiki's database schema update script.
    *   **When to use:** After a fresh installation (called by `--init`), or after upgrading MediaWiki versions, or installing new extensions that require database changes.
    *   **Data:** Modifies the database.

*   **`./manage_wiki.sh --init`**
    *   **Purpose:** Performs the initial setup of the MediaWiki project.
    *   **Action:**
        1.  Creates the empty `./mnt` directories.
        2.  Starts the Docker Compose services.
        3.  Automatically runs `php maintenance/install.php` (to create database tables and `LocalSettings.php`).
        4.  Automatically runs `php maintenance/update.php` (to finalize schema).
    *   **When to use:** Only once, for the very first setup of a fresh project.
    *   **Data:** Creates new data in `./mnt`.

*   **`./manage_wiki.sh --install_all`**
    *   **Purpose:** A convenience command that performs a complete fresh installation.
    *   **Action:** Calls `--init`.
    *   **When to use:** For a new user to get the wiki up and running with one command.
    *   **Data:** Creates new data in `./mnt`.

*   **`./manage_wiki.sh --package`**
    *   **Purpose:** Creates a tarball of the essential project files for distribution.
    *   **When to use:** When you want to share your setup with others.
    *   **Data:** Does not affect your running wiki or data.

*   **`./manage_wiki.sh --uninstall`**
    *   **Purpose:** Removes *all traces* of the MediaWiki project from your system.
    *   **Action:**
        1.  Calls `--destroy` (which performs the aggressive cleanup described above).
        2.  Then, it removes the project files themselves (`manage_wiki.sh`, `docker-compose.yml`, `.env`, `nginx.conf`, `README.md`, `TODO.md`).
    *   **When to use:** When you are completely done with the project and want to remove everything.
    *   **Important:** This command will prompt you for your `sudo` password.

---

### Host Reboot Scenario

*   **You do NOT need to run any script before rebooting your physical host.**
*   Because we set `restart: unless-stopped` in `docker-compose.yml`, Docker will automatically restart your MediaWiki containers when your host machine comes back online, *unless* you had manually stopped them with `./manage_wiki.sh --stop` before the reboot.
