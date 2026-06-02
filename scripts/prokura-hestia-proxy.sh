#!/usr/bin/env bash
set -euo pipefail

stamp=$(date +%Y%m%d-%H%M%S)

make_proxy_conf() {
  local domain="$1"
  local port="$2"
  local base="/home/user_pison/conf/web/$domain"
  local webroot="/home/user_pison/web/$domain"

  cp -a "$base/nginx.conf" "$base/nginx.conf.bak-$stamp"
  cp -a "$base/nginx.ssl.conf" "$base/nginx.ssl.conf.bak-$stamp"

  cat > "$base/nginx.conf" <<EOF_CONF
server {
        listen      103.87.67.77:80;
        server_name $domain ;
        root        $webroot/public_html;
        access_log  /var/log/nginx/domains/$domain.log combined;
        access_log  /var/log/nginx/domains/$domain.bytes bytes;
        error_log   /var/log/nginx/domains/$domain.error.log error;

        include $base/nginx.forcessl.conf*;

        location ~ /\.(?!well-known\/) {
                deny all;
                return 404;
        }

        location / {
                proxy_pass http://127.0.0.1:$port;
                proxy_http_version 1.1;
                proxy_pass_request_headers on;
                proxy_set_header Host \$host;
                proxy_set_header X-Real-IP \$remote_addr;
                proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
                proxy_set_header X-Forwarded-Proto \$scheme;
                proxy_set_header X-Forwarded-Host \$host;
                proxy_set_header X-Forwarded-Port 80;
                proxy_set_header Upgrade \$http_upgrade;
                proxy_set_header Connection \$connection_upgrade;
                proxy_cache_bypass \$http_upgrade;
                proxy_buffering off;
                proxy_read_timeout 86400;
                proxy_send_timeout 86400;
        }

        location /error/ {
                alias $webroot/document_errors/;
        }

        include $base/nginx.conf_*;
}
EOF_CONF

  cat > "$base/nginx.ssl.conf" <<EOF_SSL_CONF
server {
        listen      103.87.67.77:443 ssl;
        server_name $domain ;
        root        $webroot/public_html;
        access_log  /var/log/nginx/domains/$domain.log combined;
        access_log  /var/log/nginx/domains/$domain.bytes bytes;
        error_log   /var/log/nginx/domains/$domain.error.log error;

        ssl_certificate     $base/ssl/$domain.pem;
        ssl_certificate_key $base/ssl/$domain.key;

        if (\$anti_replay = 307) { return 307 https://\$host\$request_uri; }
        if (\$anti_replay = 425) { return 425; }

        include $base/nginx.hsts.conf*;

        location ~ /\.(?!well-known\/) {
                deny all;
                return 404;
        }

        location / {
                proxy_pass http://127.0.0.1:$port;
                proxy_http_version 1.1;
                proxy_pass_request_headers on;
                proxy_set_header Host \$host;
                proxy_set_header X-Real-IP \$remote_addr;
                proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
                proxy_set_header X-Forwarded-Proto \$scheme;
                proxy_set_header X-Forwarded-Host \$host;
                proxy_set_header X-Forwarded-Port 443;
                proxy_set_header Upgrade \$http_upgrade;
                proxy_set_header Connection \$connection_upgrade;
                proxy_cache_bypass \$http_upgrade;
                proxy_buffering off;
                proxy_read_timeout 86400;
                proxy_send_timeout 86400;
        }

        location /error/ {
                alias $webroot/document_errors/;
        }

        proxy_hide_header Upgrade;

        include $base/nginx.ssl.conf_*;
}
EOF_SSL_CONF
}

make_proxy_conf prokura-web.tierratie.com 3011
make_proxy_conf prokura-admin.tierratie.com 8501
make_proxy_conf prokura-api.tierratie.com 5010

if nginx -t; then
  systemctl reload nginx
  echo "nginx-reloaded $stamp"
else
  echo "nginx test failed; restoring backups" >&2
  for domain in prokura-web.tierratie.com prokura-admin.tierratie.com prokura-api.tierratie.com; do
    base="/home/user_pison/conf/web/$domain"
    cp -a "$base/nginx.conf.bak-$stamp" "$base/nginx.conf"
    cp -a "$base/nginx.ssl.conf.bak-$stamp" "$base/nginx.ssl.conf"
  done
  nginx -t
  exit 1
fi
