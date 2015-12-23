include wget

Exec {
    path =>  '/usr/bin:/usr/sbin:/bin:/usr/local/bin:/opt/local/bin:/usr/sfw/bin',
    logoutput => true,
}

node default {
    package { 'git':
        ensure => present,
    }

    #Install vim
    package { 'vim':
        ensure => present,
    }

    exec {'get_linux_config':
        cwd => '/home/pi',
        command => 'git clone https://github.com/justinbass/linux_config.git',
        require => [ Package['git'], Package['vim'] ],
    }

    exec {'copy_linux_config':
        cwd => '/home/pi',
        command => 'cp -r linux_config/. .',
        require => Exec['get_linux_config'],
    }

    exec {'copy_linux_config_root':
        cwd => '/home/pi',
        command => 'cp -r linux_config/. /root',
        require => Exec['get_linux_config'],
    }

    #Install tmux 2.0
    wget::fetch { 'get_tmux2_tarball':
        source      => 'http://downloads.sourceforge.net/project/tmux/tmux/tmux-2.0/tmux-2.0.tar.gz',
        destination => '/tmp/tmux-2.0.tar.gz',
        timeout     => 0,
        verbose     => false,
    }

    file { '/tmp/tmux-2.0.tar.gz':
        ensure => file,
        mode => '0755',
        source => '/tmp/tmux-2.0.tar.gz',
    }

    exec { 'untar_tmux2':
        cwd => '/tmp',
        command => 'tar xfz tmux-2.0.tar.gz',
        require => File['/tmp/tmux-2.0.tar.gz'],
    }

    package { 'libevent-dev':
        ensure => present,
    }

    package { 'libncurses5-dev':
        ensure => present,
    }

    exec { 'build_tmux2':
        cwd => '/tmp/tmux-2.0',
        command => 'ls -l configure && ./configure && make && make install',
        require => [ Exec['untar_tmux2'], Package['libevent-dev'], Package['libncurses5-dev'] ],
        onlyif => 'if [ "`tmux -V`" = "tmux 2.0" ]; then echo 0; else echo 1; fi'
    }

    exec { 'clean_tmux':
        cwd => '/tmp',
        command => 'rm tmux-2.0.tar.gz',
        require => Exec['build_tmux2'],
    }
}
