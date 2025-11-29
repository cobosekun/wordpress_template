#!/bin/bash
# Railway MySQL経由でWordPress URLを修正するスクリプト

# MySQLに接続してURLを更新
mysql -h $MYSQLHOST -P $MYSQLPORT -u $MYSQLUSER -p$MYSQLPASSWORD $MYSQLDATABASE << EOF
UPDATE wp_options SET option_value = 'https://kind-essence-production-0e51.up.railway.app' WHERE option_name = 'siteurl';
UPDATE wp_options SET option_value = 'https://kind-essence-production-0e51.up.railway.app' WHERE option_name = 'home';
SELECT option_name, option_value FROM wp_options WHERE option_name IN ('siteurl', 'home');
EOF

echo "WordPress URLs updated successfully"
