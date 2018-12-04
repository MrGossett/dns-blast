#!/bin/bash

ROOT_DOMAIN="example"
TLDS=`cat tlds`

for tld in $TLDS; do
  domain="${ROOT_DOMAIN}${tld}"
  printf "%s:\t" "$domain"
  if [[ `grep $domain existing` ]]; then
    printf "already registered\n"
    continue
  fi
  sleep 5
  available=$(aws route53domains check-domain-availability --domain-name "$domain" --query 'Availability' --output text)
  printf "$available"
  if [[ "$available" == "AVAILABLE" ]]; then
    sleep 10
    aws route53domains register-domain --cli-input-json "$(jq --arg domain $domain '.DomainName = "\($domain)"' <input.json)" >/dev/null && echo $domain >> existing && printf "\tregistered"
  elif [[ "$available" == "UNAVAILABLE" ]]; then
    echo $domain >> existing
  fi
  printf "\n"
done
