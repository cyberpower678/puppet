class openstack::neutron::l3_agent::queens(
    $dmz_cidr_array,
    $network_public_ip,
    $report_interval,
) {
    class { "openstack::neutron::l3_agent::queens::${::lsbdistcodename}": }

    $dmz_cidr = join($dmz_cidr_array, ',')
    file { '/etc/neutron/l3_agent.ini':
            owner   => 'neutron',
            group   => 'neutron',
            mode    => '0640',
            content => template('openstack/queens/neutron/l3_agent.ini.erb'),
            require => Package['neutron-l3-agent'];
    }

    # neutron-l3-agent Depends radvd on queens, but we don't use and don't
    # configure it. To prevent icinga from reporting a unit in bad shape, just
    # disable it.
    systemd::mask { 'radvd.service':
        before => Package['neutron-l3-agent'],
    }
}
