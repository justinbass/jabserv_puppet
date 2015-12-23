include tmux #shift-tmux, installs tmux 2.0 from source

$HOME = '/home/pi'

Exec {
    path =>  '/usr/bin:/usr/sbin:/bin:/usr/local/bin:/opt/local/bin:/usr/sfw/bin',
    cwd => $HOME,
    logoutput => true,
}

node default {
    #Install and configure linux_config setup
    package { 'vim':
        ensure => present,
    }

    package { 'git':
        ensure => present,
    }

    exec {'get_linux_config':
        require => [ Package['git'], Package['vim'] ],
        command => 'git clone https://github.com/justinbass/linux_config.git',
        creates => "${HOME}/linux_config",
    }

    exec {'copy_linux_config':
        require => Exec['get_linux_config'],
        command => 'cp -r linux_config/. .',
    }

    exec {'copy_linux_config_root':
        require => Exec['get_linux_config'],
        command => 'cp -r linux_config/. /root',
    }

    #Configure git ssh-key
    exec {'create_ssh_dir':
        require => Package['git'],
        command => 'mkdir .ssh',
        creates => "${HOME}/.ssh",
    }

    exec {'configure_git_ssh':
        require => Exec['create_ssh_dir'],
        command => 'ssh-keygen -t rsa -b 4096 -C "justinalanbass@gmail.com" -N "" -f ".ssh/id_rsa"',
        creates => "${HOME}/.ssh/id_rsa",
    }

    notify { 'NOTE: Make sure to add ~/.ssh/id_rsa.pub to GitHub.': require => Exec['configure_git_ssh']}

}
