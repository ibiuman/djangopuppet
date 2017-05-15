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
		command => 'sudo chown -R $(whoami).villewsgi /home/villewsgi/',
		path => '/bin:/usr/sbin:/usr/bin',
		require => [
				User['villewsgi'],
				File['/home/villewsgi/grouped/'],
				Exec['create site'],
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
		require => Exec['django-admin startproject'],
	}

	file {'/home/villewsgi/grouped/villeexamplecom/villeexamplecom/settings.py':
		ensure => 'present',
		content => template('django1/settings.py.erb'),
		require => Exec['create site'],
	}

	file {'/home/villewsgi/grouped/villeexamplecom/villeexamplecom/urls.py':
		ensure => 'present',
		content => template('django1/urls.py.erb'),
		require => Exec['create site'],
	}

	file {'/home/villewsgi/grouped/villeexamplecom/villesites/views.py':
		ensure => 'present',
		content => template('django1/views.py.erb'),
		require => Exec['create site'],
	}

	exec {'touch':
		command => 'touch wsgi.py',
		path => '/usr/bin:/bin',
		cwd => '/home/villewsgi/grouped/villeexamplecom/villeexamplecom',
		notify => Service["apache2"],
		require => [
				File['/home/villewsgi/grouped/villeexamplecom/villesites/templates/villesites/main.html'],
				File['/home/villewsgi/grouped/villeexamplecom/villeexamplecom/settings.py],				 
				File['/home/villewsgi/grouped/villeexamplecom/villeexamplecom/urls.py],
				File['/home/villewsgi/grouped/villeexamplecom/villesites/views.py],
			],

	}	
	
	exec {'make dir':
		command => 'mkdir -p templates/villesites',
		cwd => '/home/villewsgi/grouped/villeexamplecom/villesites',
		path => '/usr/bin:/bin',
		require => Exec['create site'],
	}
	
	file {'/home/villewsgi/grouped/villeexamplecom/villesites/templates/villesites/main.html':
		ensure => 'present',
		content => template('django1/main.html.erb'),
		require => Exec['make dir'],
	}



}

