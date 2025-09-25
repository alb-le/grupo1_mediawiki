# MediaWiki Docker Setup: To-Do List

This file tracks the next steps for improving the robustness and security of the Docker-based MediaWiki instance.

### High Priority

- [ ] **Implement Database Backups:** Create a reliable, automated backup script for the MariaDB database. The script should:
    - Use `mysqldump` to create a compressed backup of the `mediawiki` database.
    - Store the backup file outside of the `mnt` directory used by Docker.
    - Implement a file rotation policy (e.g., keep the last 7 daily backups).
    - Schedule the script to run automatically via a cron job.

### Medium Priority

- [ ] **Configure Automatic Startup on Host Reboot:** To ensure the wiki comes back online after a server reboot, update the `restart` policy for all services in `docker-compose.yml` from `restart: always` to `restart: unless-stopped`.

- [ ] **Set Up Log Rotation:** To prevent log files from consuming excessive disk space, configure log rotation for the services in `docker-compose.yml`. For example:
  ```yaml
  logging:
    driver: "json-file"
    options:
      max-size: "10m"
      max-file: "3"
  ```

- [ ] **Secure `.env` File:** Lock down the permissions on the `.env` file to ensure only the owner can read it.
    ```bash
    chmod 600 .env
    ```

### Low Priority / Optional

- [ ] **Transition to a Proper Reverse Proxy:** For a true production environment running multiple services, consider using a dedicated reverse proxy (like Traefik or Caddy, or even a host-level Nginx) to manage SSL certificates and routing, rather than relying on simple port mapping.

- [ ] **Monitor Container Health:** Implement a monitoring solution to check the health and resource usage of the running containers.
