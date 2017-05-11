class django1 {


	package {'apache2':
		ensure => present,
		allowcdrom => 'true',
	}

	package {"libapache2-mod-wsgi-py3":
		ensure => present,
		allowcdrom => 'true',
	}

	package {"python3-django":
		ensure => present,
		allowcdrom => 'true',
	}	
	
	service {'apache2':
		ensure => 'running',
		enable => 'true',
		require => Package["apache2"],
	}
	
	user {'villewsgi':
		ensure => 'present',
		managehome => true,
		gid => '1001',
		shell => '/bin/bash',
		groups => ['villewsgi'],
		comment => 'Ville Kauppinen WSGI user',
	}

	group {'villewsgi':
		gid => 1001,
	}

	file {'/home/villewsgi/grouped':
		ensure => 'directory',
	}

	file {'/etc/apache2/sites-enabled/000-default.conf':
		ensure => absent,
		require => Package['apache2'],
	}

	file {'/etc/apache2/sites-available/ville.conf':
		ensure => present,
		content => template('django1/ville.conf.erb'),
		require => Package['apache2'],
	}

	file {'/etc/apache2/sites-enabled/ville.conf':
		ensure => link,
		target => '/etc/apache2/sites-available/ville.conf',
		require => File['/etc/apache2/sites-available/ville.conf'],
	} 

	exec { 'django-admin startproject':
		command => 'django-admin startproject villeexamplecom',
		path => '/usr/local/bin:/usr/bin:/bin',
		cwd => '/home/villewsgi/grouped/',
		notify => Service["apache2"],
		require => File['/home/villewsgi/grouped/'],
	}

	exec { 'chmod chown':
		command => 'sudo usermod --lock villewsgi &&
				sudo chmod u=rwx,g=srwx,o=x /home/villewsgi/grouped &&
				sudo chown -R villewsgi.villewsgi /home/villewsgi/ &&
				sudo find /home/villewsgi/grouped -type f -exec chmod -v ug=rw {} \; &&
				sudo find /home/villewsgi/grouped -type d -exec chmod -v u=rwx,g=srwx {} \; &&
				sudo adduser $(whoami) villewsgi &&
				newgrp villewsgi',
		path => '/bin:/usr/sbin:/usr/bin',
		require => [
				User['villewsgi'],
				File['/home/villewsgi/grouped/'],
			],
	}

	exec {'enable wsgi':
		command => 'sudo a2enmod wsgi',
		path => '/usr/sbin/:/usr/bin/',
		require => [
				Package['apache2'],
				Package['libapache2-mod-wsgi-py3'],
			],
		notify => Service['apache2'],
	}

	package {'postgresql':
		ensure => 'present',
		allowcdrom => 'true',
	}

	package {'python3-psycopg2':
		ensure => 'present',
		allowcdrom => 'true',
	}

	exec {'createdb and user':
		command => 'sudo -u postgres createdb villewsgi && sudo -u postgres createuser villewsgi',
		path => '/usr/sbin/:/usr/bin/',
		require => Package['postgresql'],
	}

	exec {'create site':
		command => './manage.py startapp villesites',
		cwd => '/home/villewsgi/grouped/villeexamplecom/',
		path => '/home/villewsgi/grouped/villeexamplecom:/bin:/usr/bin',
	}

}

