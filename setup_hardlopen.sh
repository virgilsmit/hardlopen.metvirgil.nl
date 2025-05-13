#!/bin/bash

echo "🔧 Stop bestaande services..."
sudo systemctl stop puma || true
sudo systemctl disable puma || true

echo "🧼 Verwijder oude configuraties..."
sudo rm -f /etc/systemd/system/puma.service
sudo rm -f /etc/nginx/sites-enabled/hardlopen.metvirgil.nl
sudo rm -f /etc/nginx/sites-available/hardlopen.metvirgil.nl

echo "🛠️ Maak nieuwe Puma systemd-service..."
sudo tee /etc/systemd/system/puma.service > /dev/null <<EOF
[Unit]
Description=Puma HTTP Server
After=network.target

[Service]
Type=simple
User=vsm
WorkingDirectory=/home/vsm/webapps/hardlopen.metvirgil.nl
Environment=RAILS_ENV=production
ExecStart=/home/vsm/.rbenv/shims/bundle exec puma -C config/puma.rb
Restart=always

[Install]
WantedBy=multi-user.target
EOF

echo "🌐 Genereer Nginx configuratie..."
sudo tee /etc/nginx/sites-available/hardlopen.metvirgil.nl > /dev/null <<EOF
server {
    listen 80;
    server_name hardlopen.metvirgil.nl;

    root /home/vsm/webapps/hardlopen.metvirgil.nl/public;

    location / {
        proxy_pass http://127.0.0.1:3000;
        proxy_set_header Host \$host;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_set_header X-Real-IP \$remote_addr;
    }

    location ~ ^/assets/ {
        expires max;
        gzip_static on;
    }
}
EOF

echo "🔗 Symlink Nginx config..."
sudo ln -s /etc/nginx/sites-available/hardlopen.metvirgil.nl /etc/nginx/sites-enabled/hardlopen.metvirgil.nl

echo "🔐 Installeer/Configureer SSL met Certbot..."
sudo certbot --nginx -d hardlopen.metvirgil.nl --force-renewal --redirect

echo "🔁 Herstart services..."
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable puma
sudo systemctl start puma

sudo nginx -t && sudo systemctl reload nginx

echo "✅ Setup voltooid. Open https://hardlopen.metvirgil.nl in je browser!"
