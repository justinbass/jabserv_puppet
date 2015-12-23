include tmux

Exec {
    path =>  '/usr/bin:/usr/sbin:/bin:/usr/local/bin:/opt/local/bin:/usr/sfw/bin',
    logoutput => true,
}

node default {
    #Install and configure vim
    package { 'vim':
        ensure => present,
    }

    package { 'git':
        ensure => present,
    }

    exec {'get_linux_config':
        cwd => '/home/pi',
        command => 'git clone https://github.com/justinbass/linux_config.git',
        creates => '/home/pi/linux_config',
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

}
