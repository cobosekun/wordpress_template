<?php
/**
 * The base configuration for WordPress
 *
 * The wp-config.php creation script uses this file during the installation.
 * You don't have to use the web site, you can copy this file to "wp-config.php"
 * and fill in the values.
 *
 * This file contains the following configurations:
 *
 * * Database settings
 * * Secret keys
 * * Database table prefix
 * * Localized language
 * * ABSPATH
 *
 * @link https://wordpress.org/support/article/editing-wp-config-php/
 *
 * @package WordPress
 */

// ** Database settings - You can get this info from your web host ** //
/** The name of the database for WordPress */
define( 'DB_NAME', getenv('MYSQLDATABASE') ?: 'wordpress_db' );

/** Database username */
define( 'DB_USER', getenv('MYSQLUSER') ?: 'wordpress_user' );

/** Database password */
define( 'DB_PASSWORD', getenv('MYSQLPASSWORD') ?: 'password' );

/** Database hostname */
define( 'DB_HOST', getenv('MYSQLHOST') ? getenv('MYSQLHOST') . ':' . getenv('MYSQLPORT') : 'localhost' );

/** Database charset to use in creating database tables. */
define( 'DB_CHARSET', 'utf8' );

/** The database collate type. Don't change this if in doubt. */
define( 'DB_COLLATE', '' );

/**#@+
 * Authentication unique keys and salts.
 *
 * Change these to different unique phrases! You can generate these using
 * the {@link https://api.wordpress.org/secret-key/1.1/salt/ WordPress.org secret-key service}.
 *
 * You can change these at any point in time to invalidate all existing cookies.
 * This will force all users to have to log in again.
 *
 * @since 2.6.0
 */
define( 'AUTH_KEY',          '<xs:g]40*1MbTE]Mr4KGK_w4Z$I%(LPG}2Iq`V,.rB5oVbC?T5^ci|f:Yc5=_>a/' );
define( 'SECURE_AUTH_KEY',   '&urjg[_,$[^7G]d2< A0HW@pz{AyvR1Cp}q(nt1=| R1S)E,SEAur!d;#Q MNr3z' );
define( 'LOGGED_IN_KEY',     'U{4Xkok.yh^0;8(^<@$`,%6 *~_8[q[.eP?xpatkcMCId2zGvAj=TR;D];KVeQ-M' );
define( 'NONCE_KEY',         'p+^zX]SBv[6Cc;cz~<7|{MnDNuE9*~:ue!+j|J(iS-y9:De V%qi]Z_Ei_gv&9UY' );
define( 'AUTH_SALT',         'j*BQyW@Pk4q+KK,/x{v(%zN((P1AGM&*I[m(>5 _,dwCt`eXw}^|ChVIjln{_6+e' );
define( 'SECURE_AUTH_SALT',  '.-i&po5]N{c<Ck6o&ibs*Bi0HX7YJp2d>R3Os}Z^m)-W,-*/YjAE+@LGczH=b(cs' );
define( 'LOGGED_IN_SALT',    'C Q`ZC05x7/mih#FArm]li4rh_^V%QV3lgF:t2=L!(P_<FVhJj:;dWOYg[eCfkxx' );
define( 'NONCE_SALT',        'A%w:Q@ZF3p;JGXT){Y>(7O,s~MxL-2Od% Ag1(Mh&&uiUNc. .57Ys3Jdb/F60z#' );
define( 'WP_CACHE_KEY_SALT', 'h%`)/7)IG3rkd VETLB?7zv%iU6GWlM1T<:jlPEFH?xg4.a6-Khq5s_CqV7jb={;' );


/**#@-*/

/**
 * WordPress database table prefix.
 *
 * You can have multiple installations in one database if you give each
 * a unique prefix. Only numbers, letters, and underscores please!
 */
$table_prefix = 'wp_';


/* Add any custom values between this line and the "stop editing" line. */

// Railway configuration
if (getenv('RAILWAY_PUBLIC_DOMAIN')) {
    define('WP_HOME', 'https://' . getenv('RAILWAY_PUBLIC_DOMAIN'));
    define('WP_SITEURL', 'https://' . getenv('RAILWAY_PUBLIC_DOMAIN'));
    define('WP_CONTENT_URL', 'https://' . getenv('RAILWAY_PUBLIC_DOMAIN') . '/wp-content');
}

// Force HTTPS
if (isset($_SERVER['HTTP_X_FORWARDED_PROTO']) && $_SERVER['HTTP_X_FORWARDED_PROTO'] === 'https') {
    $_SERVER['HTTPS'] = 'on';
}



/**
 * For developers: WordPress debugging mode.
 *
 * Change this to true to enable the display of notices during development.
 * It is strongly recommended that plugin and theme developers use WP_DEBUG
 * in their development environments.
 *
 * For information on other constants that can be used for debugging,
 * visit the documentation.
 *
 * @link https://wordpress.org/support/article/debugging-in-wordpress/
 */
if ( ! defined( 'WP_DEBUG' ) ) {
	define( 'WP_DEBUG', false );
}

/* That's all, stop editing! Happy publishing. */

/** Absolute path to the WordPress directory. */
if ( ! defined( 'ABSPATH' ) ) {
	define( 'ABSPATH', __DIR__ . '/' );
}

/** Sets up WordPress vars and included files. */
require_once ABSPATH . 'wp-settings.php';
