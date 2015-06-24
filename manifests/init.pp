# == Class jmxtrans
# Installs a jmxtrans package and ensures that the jmxtrans service is running.
# The jmxtrans::metrics define includes this class, so you probably don't
# need to use it directly.
#
# == Parameters
# $run_interval - seconds between runs of jmx queries.  Default: 15
# $log_level    - level at which to log jmxtrans messages.  Default: 'info'
#
class jmxtrans(
    $run_interval = 15,
    $log_level    = 'info',
)
{
    package { 'jmxtrans':
        ensure  => 'installed',
    }

    file { '/etc/jmxtrans':
        ensure  => 'directory',
        owner   => 'jmxtrans',
        group   => 'jmxtrans',
        require => Package['jmxtrans'],
    }
    file { '/etc/default/jmxtrans':
        content => template('jmxtrans/jmxtrans.default.erb')
    }

    service { 'jmxtrans':
        ensure    => 'running',
        enable    => true,
        require   => Package['jmxtrans'],
        subscribe => File['/etc/default/jmxtrans'],
    }

    # TEMPORARY HACK.
    # https://github.com/jmxtrans/jmxtrans/issues/215
    # I cannot adjust log_level or configure log4j to
    # propertly rotate files until we have a version
    # of jmxtrans where this is fixed.  Remove all jmxtrans
    # logs for now.  We don't really need these anyway.
    cron { 'jmxtrans-log-purge':
        # This is so awful.  The version of jmxtrans we have now
        # seems to not respond to 'service jmxtrans stop'.
        command => '/usr/bin/dpkg -s jmxtrans | /bin/grep -q "Version: 250" && (/usr/bin/pkill -f "/usr/bin/java.+jmxtrans-all.jar" && sleep 6; /bin/rm -r /var/log/jmxtrans/*.log*; /usr/sbin/service jmxtrans start)',
        minute  => 0,
        hour    => 0,
        user    => 'root',
        require => Service['jmxtrans'],
    }
}
