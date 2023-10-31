#!/bin/bash
#adicionando funções ao bash
source docker-compose/functions.sh

#adicionando usuário ao grupo docker
user_docker

#iniciando banco de dados
app npm update
docker-compose up --build -d app

#atualizando permissões
permissions_update

#sudo docker-compose up -d postgres

