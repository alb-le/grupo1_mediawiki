
### Initialization

```bash
chmod +rwx manage_wiki.sh
./manage_wiki.sh --init
```

This command will:
- Stop and remove any old containers.
- Create persistent data directories under `./mnt`.
- Start all the services in the background.
- Automatically run the MediaWiki installation script using the settings from your `.env` file.

### Access Your Wiki

After the `init` script finishes, you can access your new wiki in your web browser. By default, it will be available at:

**`http://localhost:8080`**

(If you changed `HOST_PORT` in your `.env` file, use that port instead).

## Management

The `manage_wiki.sh` script provides a simple interface for managing the lifecycle of your MediaWiki environment.

| Command | Description |
| :--- | :--- |
| `./manage_wiki.sh --init` | Initializes the environment, creates directories, and starts the stack for the first time. |
| `./manage_wiki.sh --run` | Starts all MediaWiki services in the background. |
| `./manage_wiki.sh --stop` | Stops all services and removes the containers. |
| `./manage_wiki.sh --freeze` | Pauses all running services. |
| `./manage_wiki.sh --resume` | Resumes services from a paused state. |
| `./manage_wiki.sh --shell-app` | Opens a bash shell inside the MediaWiki application container. |
| `./manage_wiki.sh --shell-db` | Opens a bash shell inside the MariaDB container. |
| `./manage_wiki.sh --shell-web` | Opens a bash shell inside the Nginx web container. |
| `./manage_wiki.sh --destroy` | Stops all services and **PERMANENTLY DELETES ALL DATA** in the volumes. |
| `./manage_wiki.sh --update` | Runs the MediaWiki database update script (`update.php`). Useful after upgrades or extension installs. |
| `./manage_wiki.sh --install_all` | A convenience alias for the `--init` command. |
| `./manage_wiki.sh --package` | Creates a `.tar.gz` archive of the essential project files for distribution. |
| `./manage_wiki.sh --uninstall` | A destructive command that runs `--destroy` and then removes the local `mnt` directory. |
| `./manage_wiki.sh --help` | Displays the help message. |

## Persistent Data

This project is configured to persist critical data on your host machine inside the `mnt` directory:

-   **Database Files:** All MariaDB data is stored in `./mnt/db`.
-   **MediaWiki Configuration:** Your generated `LocalSettings.php` is stored in `./mnt/config`.
-   **MediaWiki Images/Uploads:** While not explicitly mapped in this version, uploaded files would be stored within the `mediawiki_code` volume. For a production setup, you would add a specific volume for `./mnt/images` mapped to the correct uploads directory.

## Original project

This project was forked from JimDunphy [project](https://github.com/JimDunphy/docker-mediawiki).