# === define: query_service::blazegraph
# Note: This resource installs and start the blazegraph service
#
# == Parameters:
# - $port: Blazegraph port to run on
# - $config_file_name: The name of the config file for this instance
# - $package_dir:  Directory where the service should be installed.
# - $data_dir: Directory where the database should be stored
# - $logstash_host: hostname where to send logs
# - $logstash_json_port: port on which to send logs in json format
# - $logstash_logback_port: port which rsyslog server is listening on
# - $log_dir: Directory where the logs go
# - $heap_size: heapsize for blazegraph
# - $username: Username owning the service
# - $deploy_user: username of deploy user
# - $use_deployed_config: Whether we should use config in deployed repo or our own
# - $options: options for Blazegraph startup script
# - $extra_jvm_opts: Extra JVM configs for blazegraph
# - $logstash_transport: send logs directly or via rsyslog
define query_service::blazegraph(
    Stdlib::Port $port,
    String $config_file_name,
    Stdlib::Unixpath $package_dir,
    Stdlib::Unixpath $data_dir,
    String $deploy_name, # TODO: we should use $title for this.
    Stdlib::Port $logstash_logback_port,
    Stdlib::Unixpath $log_dir,
    String $heap_size,
    String $username,
    Boolean $use_deployed_config,
    Array[String] $options,
    Array[String] $extra_jvm_opts,
) {
    if ($use_deployed_config) {
        $config_file = $config_file_name
    } else {
        $config_file = "/etc/${deploy_name}/${config_file_name}"
        file { $config_file:
            ensure  => file,
            content => template("query_service/${config_file_name}.erb"),
            owner   => 'root',
            group   => 'root',
            mode    => '0644',
            before  => Systemd::Unit[$title],
        }
    }

    file { "/etc/default/${title}":
        ensure  => present,
        content => template('query_service/blazegraph-default.erb'),
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        before  => Systemd::Unit[$title],
    }

    query_service::logback_config { $title:
        logstash_logback_port => $logstash_logback_port,
        deploy_name           => $deploy_name,
        log_dir               => $log_dir,
        pattern               => '%d{HH:mm:ss.SSS} [%thread] %-5level %logger{36} - %msg %mdc%n%rEx{1,QUERY_TIMEOUT,SYNTAX_ERROR}',
        evaluators            => true,
    }

    # Blazegraph service
    systemd::unit { $title:
        content => template('query_service/initscripts/blazegraph.systemd.erb'),
    }

    service { $title:
        ensure => 'running',
    }

}