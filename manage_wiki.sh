#!/bin/bash
#set -e
#set -x

# Ensure we are running from the script's directory
cd "$(dirname "$0")"

# --- Help Function ---
display_help() {
    echo "Usage: $0 {--init|--run|--stop|--freeze|--resume|--shell-app|--shell-db|--shell-web|--destroy|--update|--install_all|--package|--uninstall|--help}"
    echo ""
    echo "   --init         Initializes the environment. Creates required directories and starts the stack."
    echo "   --run          Starts all MediaWiki services in the background."
    echo "   --stop         Stops all services and removes the containers."
    echo "   --freeze       Pauses all running services."
    echo "   --resume       Resumes services from a paused state."
    echo "   --shell-app    Opens a bash shell inside the MediaWiki application container for debugging."
    echo "   --shell-db     Opens a bash shell inside the MariaDB container for debugging."
    echo "   --shell-web    Opens a bash shell inside the Nginx web container for debugging."
    echo "   --destroy      Stops all services and PERMANENTLY DELETES ALL DATA in the volumes."
    echo "   --update       Runs MediaWiki database update script (for upgrades/extensions)."
    echo "   --install_all  Performs a complete fresh installation (init + update)."
    echo "   --package      Creates a tarball of the essential setup files for distribution."
    echo "   --uninstall    Stops all services, deletes all data, and removes all project files."
    echo "   --help         Displays this help message."
    echo ""
}

# --- Main Logic ---
case "$1" in
    --init)
        echo "Initializing MediaWiki environment..."
        docker compose down
        if [ -f ./mnt/config/LocalSettings.php ]; then
            echo "MediaWiki is already installed. Starting services."
            docker compose up -d
            exit 0
        fi

        echo "Creating persistent data directories..."
        mkdir -p ./mnt/config
        mkdir -p ./mnt/db
        mkdir -p ./mnt/images
        echo "Starting services and running installer..."
        docker compose up -d
        echo "Monitoring installation... (this may take a moment)"

        # Wait for the installer to complete by checking for LocalSettings.php
        while [ ! -f ./mnt/config/LocalSettings.php ]; do
            echo -n "."
            sleep 5
            # Check if the installer container has exited with an error
            if [ "$(docker ps -a -f name=mediawiki-installer -f status=exited --format '{{.Status}}')" ]; then
                echo -e "\n\nError: The MediaWiki installer container exited unexpectedly."
                echo "Please check the logs for errors: docker logs mediawiki-installer"
                exit 1
            fi
done

        # Copy LocalSettings.php from the installer's volume to the host
        echo "\nInstallation detected, copying LocalSettings.php to host..."
        docker cp mediawiki-installer:/var/www/html/LocalSettings.php ./mnt/config/LocalSettings.php

        echo "Installation complete. MediaWiki is starting up."
        echo "You can access it at http://localhost:${HOST_PORT:-8080} or your host's IP address."
        ;;
    --run)
        echo "Starting MediaWiki services..."
        docker compose up -d
        ;;
    --stop)
        echo "Stopping MediaWiki services..."
        docker compose down
        ;;
    --freeze)
        echo "Freezing (pausing) running services..."
        docker compose pause
        ;;
    --resume)
        echo "Resuming services..."
        docker compose unpause
        ;;
    --shell-app)
        echo "Opening shell into mediawiki-app container..."
        docker exec -it mediawiki-app /bin/bash
        ;;
    --shell-db)
        echo "Opening shell into mediawiki-db container..."
        docker exec -it mediawiki-db /bin/bash
        ;;
    --shell-web)
        echo "Opening shell into mediawiki-web container..."
        docker exec -it mediawiki-web /bin/bash
        ;;
    --destroy)
        echo "PERMANENTLY DESTROYING all containers and data volumes..."
        docker stop mediawiki-web mediawiki-app mediawiki-db mediawiki-installer || true
        docker rm mediawiki-web mediawiki-app mediawiki-db mediawiki-installer || true
        docker compose down --volumes
        echo "Removing bind-mounted data (requires sudo for permissions)..."
        sudo rm -rf ./mnt/db/* ./mnt/config/* ./mnt/images/* || true
        echo "Cleanup complete."
        ;;
    --update)
        echo "Running MediaWiki database update script..."
        docker compose exec mediawiki php maintenance/update.php
        ;;
    --install_all)
        echo "Starting complete MediaWiki installation..."
        "$0" --init
        ;;
    --package)
        echo "Creating MediaWiki setup package..."
        PACKAGE_NAME="mediawiki_docker_setup_$(date +%Y%m%d%H%M%S).tar.gz"
        tar -czvf "../$PACKAGE_NAME" README.md Internals.md .gitignore .env docker-compose.yml manage_wiki.sh nginx.conf
        echo "Package created: ../$PACKAGE_NAME"
        ;;
    --uninstall)
        echo "Starting complete MediaWiki uninstallation..."
        "$0" --destroy
        echo "Removing persistent data directory..."
        rm -rf ./mnt
        # echo "Removing project files..."
        # rm -f manage_wiki.sh docker-compose.yml .env nginx.conf README.md TODO.md How_2_Use.md
        echo "Uninstallation complete. This directory is now empty."
        ;;
    --help)
        display_help
        ;;
    *)
        echo "Error: Invalid argument."
        echo ""
        display_help
        exit 1
        ;;
esac

exit 0
