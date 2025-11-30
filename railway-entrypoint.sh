#!/bin/bash
set -e

echo "=== Debug Info ==="
echo "MYSQLHOST: ${MYSQLHOST:-NOT SET}"
echo "MYSQLPORT: ${MYSQLPORT:-NOT SET}"
echo "MYSQLUSER: ${MYSQLUSER:-NOT SET}"
echo "MYSQLDATABASE: ${MYSQLDATABASE:-NOT SET}"
echo "=================="

# Wait for MySQL to be ready
echo "Waiting for MySQL..."
until mysql -h "$MYSQLHOST" -P "$MYSQLPORT" -u "$MYSQLUSER" -p"$MYSQLPASSWORD" --skip-ssl -e "SELECT 1" >/dev/null 2>&1; do
  echo "MySQL is unavailable - sleeping"
  sleep 2
done
echo "MySQL is up"

# Update WordPress URLs in database if RAILWAY_PUBLIC_DOMAIN is set
if [ -n "$RAILWAY_PUBLIC_DOMAIN" ]; then
  echo "Updating WordPress URLs in database..."
  SITE_URL="https://$RAILWAY_PUBLIC_DOMAIN"
  
  mysql -h "$MYSQLHOST" -P "$MYSQLPORT" -u "$MYSQLUSER" -p"$MYSQLPASSWORD" "$MYSQLDATABASE" --skip-ssl <<-EOSQL
    UPDATE wp_options SET option_value='$SITE_URL' WHERE option_name='siteurl';
    UPDATE wp_options SET option_value='$SITE_URL' WHERE option_name='home';
EOSQL
  
  echo "WordPress URLs updated in database"
fi

# Configure Apache port (Railway uses PORT environment variable)
PORT=${PORT:-8080}
echo "Configuring Apache to listen on port $PORT..."
sed -i "s/Listen 80/Listen $PORT/g" /etc/apache2/ports.conf
sed -i "s/:80/:$PORT/g" /etc/apache2/sites-available/000-default.conf

echo "Starting Apache..."
