#!/bin/bash

#funções uteis
# Função para verificar e criar o arquivo .env se necessário
create_env_file() {
  if [ ! -f .env ]; then
    cp .env.example .env
    echo -e "Arquivo .env não encontrado, ${green}criado novo .env a partir de .env.example${reset}"
  fi
}

# Verificar e criar o arquivo .env se necessário
create_env_file

#comando para matar todos os containers
function dka(){
    docker kill $(docker ps -q)
    echo "${green}Todos os containers em execução foram derrubados.{reset}"
}

#reinicia a aplicação e mostra os logs do app
function dua(){
    docker-compose down && docker-compose up -d
    docker attach $APP_NAME'_app'
}

# Função para instalar Docker e Docker Compose
install_docker_compose() {
    # Verifica se o Docker está instalado
    if ! [ -x "$(command -v docker)" ]; then
        echo "Instalando Docker"
        # Instala Docker
        curl -fsSL https://get.docker.com -o get-docker.sh
        sudo sh get-docker.sh
        sudo usermod -aG docker $USER
        # Inicia serviço do Docker
        sudo systemctl start docker
        sudo systemctl enable docker
        # Remove script de instalação
        rm get-docker.sh
    else
        echo "Docker já está instalado"
    fi
    
    # Verifica se o Docker Compose está instalado
    if ! [ -x "$(command -v docker-compose)" ]; then
        echo "Instalando Docker Compose"
        # Instala Docker Compose
        sudo curl -L "https://github.com/docker/compose/releases/download/1.29.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        sudo chmod +x /usr/local/bin/docker-compose
    else
        echo "Docker Compose já está instalado"
    fi
}

# Chama a função de instalação do Docker e Docker Compose
install_docker_compose

function getEnv(){
    eval "$(
    cat .env | awk '!/^\s*#/' | awk '!/^\s*$/' | while IFS='' read -r line; do
        key=$(echo "$line" | cut -d '=' -f 1)
        value=$(echo "$line" | cut -d '=' -f 2-)
        echo "export $key=\"$value\""
    done
    )"
}

getEnv

function user_docker(){
    if id -nG "$USER" | grep -qw "docker"; then
        echo $USER belongs to docker group
    else
        sudo usermod -aG docker ${USER}
        echo $USER has added to the docker group
    fi
}

function enter(){
    docker exec -it $@ bash
}

function app(){
    if [ $1 == "new" ]; then
        echo criando $2
        new_app
        app_turbolink_remove
        atualiza_nome_app $2
        docker-compose up -d
    elif [ $1 == "enter" ]; then
        enter $APP_NAME'_app'
    else
        docker-compose run app $@
    fi
}

function permissions_update(){
    sudo chown -R $USER:$USER .env
    sudo chown -R $USER:$USER .gitignore
    sudo chown -R $USER:$USER Dockerfile
    sudo chown -R $USER:$USER README.md
    sudo chown -R $USER:$USER docker-compose/functions.sh
    echo permissões atualisadas!
}

function prune(){
    docker system prune -a -f
}

function restart(){
    docker-compose down
    prune
    source start.sh
}

function se_existe(){
    file=$1
    if [ -f "$file" ] || [ -d "$file" ]
    then
        $2
    fi
}

function Welcome(){
    echo funções carregadas!
}

Welcome
