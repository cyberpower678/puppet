# Class: squid3
#
# This class installs Squid and configures it
#
# Parameters:
#
# Actions:
#       Install Squid and configure it as a caching forward proxy
#
# Requires:
#
# Sample Usage:
#   class { 'squid3': config_source => 'puppet:///modules/foo/squid3-foo.conf' }
#   class { 'squid3': config_content => template('foo/squid3-foo.conf.erb') }


class squid3(
    Wmflib::Ensure $ensure  = present,
    $config_content = undef,
    $config_source  = undef,
) {

    file { '/etc/squid/squid.conf':
        ensure  => $ensure,
        mode    => '0444',
        owner   => 'root',
        group   => 'root',
        source  => $config_source,
        content => $config_content,
        require => Package['squid'],
    }

    logrotate::conf { 'squid':
        ensure => $ensure,
        source => 'puppet:///modules/squid3/squid-logrotate',
    }

    package { 'squid':
        ensure => $ensure,
    }

    service { 'squid':
        ensure    => ensure_service($ensure),
        require   => File['/etc/squid/squid.conf'],
        subscribe => File['/etc/squid/squid.conf'],
    }

    systemd::unit { 'squid':
        content  => init_template('squid', 'systemd_override'),
        override => true,
        restart  => true,
    }
}
