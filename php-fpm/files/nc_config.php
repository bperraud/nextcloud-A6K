<?php

$CONFIG = [
  'trusted_proxies' => ['10.0.0.0/8', '172.16.0.0/12', '192.168.0.0/16'],
  'overwrite.cli.url' => 'https://cloud.example.com',
  'trusted_domains' => [
    'localhost',
    'cloud.example.com',
    'nextcloud',
    'nextcloud.localdomain'
  ],
  'datadirectory' => '/srv/data',
  'appcodechecker' => true,
  'updatechecker' => false,
  'updater.server.url' => 'https://updates.nextcloud.com/updater_server/',
  'updater.release.channel' => 'stable',
  'has_internet_connection' => true,
  'connectivity_check_domains' => [
    'www.nextcloud.com',
    'www.startpage.com',
    'www.eff.org',
    'www.edri.org'
  ],
  'check_for_working_wellknown_setup' => true,
  'check_for_working_htaccess' => true,
  'check_data_directory_permissions' => false,
  'config_is_read_only' => false,
  'log_type' => 'file',
  'logfilemode' => 0640,
  'loglevel' => 2,
  'appstoreenabled' => false,
  'apps_paths' => [
    [
      'path'=> '/var/www/html/custom_apps',
      'url' => '/custom_apps',
      'writable' => false,
    ],
    [
      'path'=> '/var/www/html/apps',
      'url' => '/apps',
      'writable' => false,
    ],
  ],
  'maintenance' => false,
  'memcache.local' => '\OC\Memcache\APCu',
  'memcache.distributed' => '\OC\Memcache\Redis',
  'memcache.locking' => '\OC\Memcache\Redis',
  'redis.cluster' => [
    'seeds' => [
      'redis-cluster-0:6379',
      'redis-cluster-1:6379',
      'redis-cluster-2:6379'
    ],
    'timeout' => 0.0,
    'read_timeout' => 0.0,
    'failover_mode' => \RedisCluster::FAILOVER_ERROR,
  ],
  'tempdirectory' => '/srv/data/_nctmp',
  'filelocking.enabled' => true,
  'upgrade.disable-web' => true
];
?>
