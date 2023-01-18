curl -X PUT "$CLOUDFLARE_URL/client/v4/zones/$ZONE_ID/dns_records/$RECORD_ID" \
     -H "Authorization: Bearer $API_TOKEN" \
     -H "Content-Type: application/json" \
     --data "{\"type\":\"A\",\"name\":\"$NAME\",\"content\":\"`dig +short myip.opendns.com @resolver1.opendns.com`\",\"proxied\":true,\"ttl\":1}"
