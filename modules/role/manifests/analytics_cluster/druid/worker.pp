# == Class role::analytics_cluster::druid::worker
# For the time being, all Druid services are hosted on all druid nodes
# in the Analytics Cluster.  This may change if and when we expand
# the Druid cluster beyond 3 nodes.
#
# Note that if /etc/hadoop/conf files exist, they will
# be added to druid daemon
#
# filtertags: labs-project-analytics
class role::analytics_cluster::druid::worker {

    # Require common druid package and configuration.
    require ::profile::druid::common
    require ::profile::hadoop::client

    # Zookeeper is co-located on the same host
    include profile::zookeeper::server
    include profile::zookeeper::firewall

    # Auto reload daemons in labs, but not in production.
    $should_subscribe = $::realm ? {
        'labs'  => true,
        default => false,
    }

    # Druid Broker Service
    class { '::druid::broker':
        should_subscribe => $should_subscribe,
    }

    # Druid Coordinator Service
    class { '::druid::coordinator':
        should_subscribe => $should_subscribe,
    }

    # Druid Historical Service
    class { '::druid::historical':
        should_subscribe => $should_subscribe,
    }

    # Druid MiddleManager Indexing Service
    class { '::druid::middlemanager':
        should_subscribe => $should_subscribe,
    }

    # Druid Overlord Indexing Service
    class { '::druid::overlord':
        should_subscribe => $should_subscribe,
    }
}
