curl -X PUT "$CLOUDFLARE_URL/client/v4/zones/$ZONE_ID/dns_records/$RECORD_ID" \
     -H "Authorization: Bearer $API_TOKEN" \
     -H "Content-Type: application/json" \
     --data "{\"type\":\"A\",\"name\":\"$NAME\",\"content\":\"`curl ifconfig.co`\",\"proxied\":true,\"ttl\":1}"