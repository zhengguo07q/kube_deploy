
docker_build_all:
	@echo "[docker_build_all]"
	@docker-compose -f ./dev/docker-compose.yaml up --pull always --dry-run -d

