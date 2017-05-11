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
	}

	exec { 'chmod chown':
		command => 'usermod --lock villewsgi;chmod u=rwx,g=srwx,o=x /home/villewsgi/grouped;chown -R villewsgi.villewsgi /home/villewsgi/;
				find /home/villewsgi/grouped -type f -exec chmod -v ug=rw {} \;;
				find /home/villewsgi/grouped -type d -exec chmod -v u=rwx,g=srwx {} \;;
				adduser $(whoami) villewsgi;
				newgrp villewsgi',
		path => '/bin:/usr/sbin:/usr/bin',
	}


}
