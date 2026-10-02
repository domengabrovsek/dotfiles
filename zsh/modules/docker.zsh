# ============================================================================
# Docker
# ============================================================================

# --- Environment ---

# Enable docker compose build optimization
export COMPOSE_BAKE=true

# Docker BuildKit (faster builds)
export DOCKER_BUILDKIT=1
export COMPOSE_DOCKER_CLI_BUILD=1

# --- Aliases ---

alias d='docker'
alias dc='docker compose'
alias dps='docker ps'
alias dpsa='docker ps -a'
alias di='docker images'
alias dex='docker exec -it'
alias dlogs='docker logs -f'
alias dstop='docker stop'
alias drm='docker rm'
alias drmi='docker rmi'
alias dprune='docker system prune -af --volumes'

# Docker Compose
alias dcup='docker compose up'
alias dcupd='docker compose up -d'
alias dcdown='docker compose down'
alias dcbuild='docker compose build'
alias dcps='docker compose ps'
alias dclogs='docker compose logs -f'
alias dcexec='docker compose exec'
alias dcrestart='docker compose restart'

# --- Functions ---

# Stop all running containers
docker_stop_all() {
  docker stop $(docker ps -q)
}

# Remove all dangling images
docker_clean_images() {
  docker rmi $(docker images -f "dangling=true" -q)
}

# Complete Docker cleanup (containers, images, volumes, networks)
docker_nuke() {
  echo "⚠️  This will remove all Docker containers, images, volumes, and networks!"
  echo -n "Are you sure? (y/N): "
  read confirm
  if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
    docker system prune -af --volumes
    echo "✨ Docker cleanup complete!"
  else
    echo "Cancelled."
  fi
}

# Show Docker disk usage
docker_disk_usage() {
  docker system df -v
}

# Enter a running container with sh or bash
dsh() {
  if [[ -z "$1" ]]; then
    echo "Usage: dsh <container_name_or_id>"
    return 1
  fi

  # Try bash first, fall back to sh
  docker exec -it "$1" bash 2>/dev/null || docker exec -it "$1" sh
}

# --- Completion ---

# Docker CLI completions (if Docker Desktop installed)
if [[ -d ~/.docker/completions ]]; then
  fpath=(~/.docker/completions $fpath)
fi

# --- Help ---

_zhelp_register docker <<'HELP'
d / dc        docker / docker compose
dps / dpsa    docker ps / ps -a
di / dex      docker images / exec -it
dlogs / dstop docker logs -f / stop
drm / drmi    docker rm / rmi
dprune        docker system prune -af --volumes
dcup / dcupd  compose up / up -d
dcdown        compose down
dcbuild       compose build
dcps / dclogs compose ps / logs -f
dcexec        compose exec
dcrestart     compose restart
dsh <ctr>     exec into container (bash/sh)
docker_stop_all       stop all containers
docker_clean_images   remove dangling images
docker_nuke           full cleanup (with confirm)
docker_disk_usage     show disk usage
HELP
