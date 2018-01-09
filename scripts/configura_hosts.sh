#!/bin/bash

# Vagrantfile coloca as configurações dos nós gerenciados (IP, FQDN e nome)
# no arquivo 'files/hosts' do projeto
ARQ_CONFS='/etc/hosts'
ARQ_NOVOS='/vagrant/files/hosts'

# Lê as configurações dos nós gerenciados por linha - um nó por vez
while read LINHA_NOVA ; do

  # Parâmetros do nó gerenciado a tratar
  IPv4=$(echo "$LINHA_NOVA" | awk '{ print $1 }')
  FQDN=$(echo "$LINHA_NOVA" | awk '{ print $2 }')
  NOME=$(echo "$LINHA_NOVA" | awk '{ print $3 }')

  # Coleta os números das linhas do arquivo /etc/hosts
  # com o IP ou o nome do nó gerenciado
  LINHAS_PARECIDAS=$(grep -nE "${IPv4}|${NOME}" "$ARQ_CONFS" | cut -d: -f 1 | tac)

  # Caso haja mais de uma linha com o nó gerenciado, deixa apenas a primeira
  if [ $(echo "$LINHAS_PARECIDAS" | wc -l) -gt 1 ] ; then
    for REMOVER in $(echo "$LINHAS_PARECIDAS" | head -n -1) ; do
      sed -i "${REMOVER}d" "$ARQ_CONFS"
    done
  fi

  # Caso tenha ficado uma linha com o nó, verifica se está correta
  if [ -n "$LINHAS_PARECIDAS" ] ; then
    SUBSTITUIR=$(echo "$LINHAS_PARECIDAS" | tail -1)
    # Caso haja alguma diferença, substitui a linha pela correta
    if [ "$(sed -n "${SUBSTITUIR}p" "$ARQ_CONFS")" != "$LINHA_NOVA" ] ; then
      sed -i "${SUBSTITUIR}c${LINHA_NOVA}" "$ARQ_CONFS"
    fi
  # Caso não haja linha com o nó, inclui linha correta
  else
    echo "$LINHA_NOVA" >> "$ARQ_CONFS"
  fi

done < "$ARQ_NOVOS"
