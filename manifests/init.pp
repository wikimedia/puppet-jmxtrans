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
}
