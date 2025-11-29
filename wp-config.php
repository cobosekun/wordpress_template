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
define( 'DB_NAME', 'wordpress_db' );

/** Database username */
define( 'DB_USER', 'wordpress_user' );

/** Database password */
define( 'DB_PASSWORD', 'password' );

/** Database hostname */
define( 'DB_HOST', 'localhost' );

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
define( 'AUTH_KEY',          'xS@uxVvoRaT%&o[ewTgSP/U#SMa|MGP}y^Yop0eCP,#4MR+B^;5`q~/]+)7cmQM3' );
define( 'SECURE_AUTH_KEY',   'pad;q8_jk,|YAcH-5y{v=@$^1VFyijCe}~oBOTd0>?QhlGH |U%jWo<*sH-X23|=' );
define( 'LOGGED_IN_KEY',     ';4_u)O>Cp WJKdFhmC%c=<qiJ8k{RIiwNS]9p;fx3P*2u+OZX=PDND3=-sP.++8Y' );
define( 'NONCE_KEY',         '*J)JS3<v*O3e 19N`}/[,15)HnWm?4a!V@Q4N>p]U]6//Q;%Q~MU1-(P6[;=Fzs/' );
define( 'AUTH_SALT',         'U=sVFW_+NtAGs;U#d |SWwfl=;`!I82kPcS}if0N(O|nVMgZ|m<Ou]i/VY+TS4wP' );
define( 'SECURE_AUTH_SALT',  'ieY*HS(FgoG3t-y7.saVmP4nLz;KSofu#s)<4kW$j8cimw8g,T;4k%yHLo}Z(;KX' );
define( 'LOGGED_IN_SALT',    '1DnC;{KgG0-f{,5fP@xUDxXbaw*:^Z,(8_ana,iE17C8;mu_/lbl;(l[xg~(:J!O' );
define( 'NONCE_SALT',        '-,*ns|rW8_Fm}rMaZQgwMVAWQ}^QD1oBMFnr;8OR.Qe31@@1*JLy E)63l~^o9bk' );
define( 'WP_CACHE_KEY_SALT', '9B[IEzSHX+|dILyqhP=9Mi`8IRG:VCZR8Nc)S>#^SD<;q!cf$:A#WgN#`eBMLl|r' );


/**#@-*/

/**
 * WordPress database table prefix.
 *
 * You can have multiple installations in one database if you give each
 * a unique prefix. Only numbers, letters, and underscores please!
 */
$table_prefix = 'wp_';


/* Add any custom values between this line and the "stop editing" line. */



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

// Force HTTPS and disable redirects
define('FORCE_SSL_ADMIN', false);
define('WP_HOME', 'https://kind-essence-production-0e51.up.railway.app');
define('WP_SITEURL', 'https://kind-essence-production-0e51.up.railway.app');

/* That's all, stop editing! Happy publishing. */

/** Absolute path to the WordPress directory. */
if ( ! defined( 'ABSPATH' ) ) {
	define( 'ABSPATH', __DIR__ . '/' );
}

/** Sets up WordPress vars and included files. */
require_once ABSPATH . 'wp-settings.php';
