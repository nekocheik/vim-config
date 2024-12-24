# Construire l'image Docker
build:
	docker-compose build

# Lancer le conteneur
up:
	docker-compose up -d

# Arrêter le conteneur
down:
	docker-compose down

# Accéder au conteneur
shell:
	docker-compose exec -it nvim /bin/bash || docker-compose start nvim && docker-compose exec -it nvim /bin/bash

# Lancer Neovim directement
nvim:
	docker-compose exec -it nvim nvim || docker-compose start nvim && docker-compose exec -it nvim nvim

# Mettre à jour la configuration
update:
	docker-compose down
	docker-compose build
	docker-compose up -d

# Supprimer complètement le conteneur et l'image
remove:
	docker-compose down
	docker rmi nvim-nvim
	docker system prune -f

# Voir les logs
logs:
	docker-compose logs -f nvim

# Vérifier le statut
status:
	docker-compose ps

# Initialiser l'environnement de travail
init:
	mkdir -p workspace
	mkdir -p .config/nvim

# Modifier la commande restart-0 pour inclure l'initialisation
restart-0: init
	docker-compose down || true
	docker rmi nvim-ide || true
	docker-compose up -d --build

# Mettre à jour uniquement la configuration Vim
update-config:
	docker-compose cp .config/nvim/. nvim:/root/.config/nvim/
	docker-compose restart nvim

# Commande start pour l'environnement Neovim Docker
start:
	@echo "🚀 Démarrage de l'environnement Neovim Docker..."
	@if [ ! -d "workspace" ] || [ ! -d ".config/nvim" ]; then \
		echo "📁 Initialisation des dossiers..."; \
		$(MAKE) init; \
	fi
	@if ! docker ps -q -f name=nvim-ide >/dev/null 2>&1; then \
		if ! docker ps -aq -f name=nvim-ide >/dev/null 2>&1; then \
			echo "🏗️  Construction du conteneur..."; \
			$(MAKE) build; \
			echo "▶️  Démarrage du conteneur..."; \
			$(MAKE) up; \
		else \
			echo "▶️  Redémarrage du conteneur existant..."; \
			docker start nvim-ide; \
		fi \
	else \
		echo "✅ Le conteneur est déjà en cours d'exécution"; \
	fi
	@echo "🚪 Connexion à Neovim..."
	@sleep 2
	docker exec -it nvim-ide nvim