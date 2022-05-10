#!/bin/bash

ROOT_DOMAIN="example"
TLDS=`cat tlds`

for tld in $TLDS; do
  domain="${ROOT_DOMAIN}${tld}"
  grep $domain existing && continue
  printf "%s:\t" "$domain"
  sleep 1
  available=$(aws route53domains check-domain-availability --domain-name "$domain" --query 'Availability' --output text --region us-east-1)
  printf "$available"

  if [[ "$available" == "AVAILABLE" ]]; then
    sleep 10
    aws route53domains register-domain --cli-input-json "$(jq --arg domain $domain '.DomainName = "\($domain)"' <input.json)" >/dev/null && echo $domain >> existing && printf "\tregistered"

  elif [[ "$available" == "UNAVAILABLE" ]]; then
    echo $domain >> existing

  elif [[ "$available" != "PENDING" ]]; then
    printf "%s:\t%s\n" "$domain" "$available" >> existing
  fi

  printf "\n"
done
