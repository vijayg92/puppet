class newrelic::remove {

    $packagelist = ['newrelic-sysmond', 'newrelic-repo']

    service { 'newrelic-sysmond':
        ensure => stopped,
        enable => false
    }

    package { $packagelist:
        ensure  => absent,
        require => Service['newrelic-sysmond']
    }
}
