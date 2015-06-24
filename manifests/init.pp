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
    # jmxtrans will function fine if its open log
    # file is removed.
    exec { 'jmxtrans-log-purge':
        command => '/bin/rm /var/log/jmxtrans/*.log*',
        user    => 'jmxtrans',
        onlyif  => '/usr/bin/dpkg -s jmxtrans | grep -q "Version: 250"',
        require => Service['jmxtrans'],
    }
}
