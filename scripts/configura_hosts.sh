#!/bin/bash

ARQ_CONFS='/etc/hosts'
ARQ_NOVOS='/vagrant/files/hosts'

while read LINHA_NOVA ; do
  IPv4=$(echo "$LINHA_NOVA" | awk '{ print $1 }')
  FQDN=$(echo "$LINHA_NOVA" | awk '{ print $2 }')
  NOME=$(echo "$LINHA_NOVA" | awk '{ print $3 }')
  LINHAS_PARECIDAS=$(grep -nE "${IPv4}|${NOME}" "$ARQ_CONFS" | cut -d: -f 1 | tac)
  if [ $(echo "$LINHAS_PARECIDAS" | wc -l) -gt 1 ] ; then
    for REMOVER in $(echo "$LINHAS_PARECIDAS" | head -n -1) ; do
      sed -i ${REMOVER}d "$ARQ_CONFS"
    done
  fi
  if [ -n "$LINHAS_PARECIDAS" ] ; then
    SUBSTITUIR=$(echo "$LINHAS_PARECIDAS" | tail -1)
    if [ "$(sed -n "${SUBSTITUIR}p" "$ARQ_CONFS")" != "$LINHA_NOVA" ] ; then
      sed -i "${SUBSTITUIR}c${LINHA_NOVA}" "$ARQ_CONFS"
    fi
  else
    echo "$LINHA_NOVA" >> "$ARQ_CONFS"
  fi
done < "$ARQ_NOVOS"
