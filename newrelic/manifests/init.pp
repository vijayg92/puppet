class newrelic($ensure='present', $autoupgrade='false', $license_key=undef){
    if ! $license_key {
      fail("You must specify a valid License Key!!")
    }

    if !( $ensure in ['present', 'absent']) {
        fail("NewRelic ensure parameter must be absent or present!!")
    }

    if !( $autoupgrade in ['true', 'false']) {
        fail("NewRelic auto-upgrade parameter must be true or false!!")
    }

    if ( $ensure == 'present') {
          $service_enable = true
          $service_ensure = running
          if ( $autoupgrade == 'true') {
              $package_ensure = latest
          }
          else {
              $package_ensure = present
          }
    }
    else {
          $service_enable = false
          $service_ensure = stopped
          $package_ensure = absent
    }

    package { "NewRelic-RPM":
      ensure   => $package_ensure,
      source   => "http://yum.newrelic.com/pub/newrelic/el5/x86_64/newrelic-repo-5-3.noarch.rpm",
      provider => rpm
    }

    file { "nrsysmond.cfg":
        ensure  => present,
        path    => '/etc/newrelic/nrsysmond.cfg',
        owner   => 'newrelic',
        group   => 'newrelic',
        mode    => '0644',
        content => template('newrelic/nrsysmond.cfg.erb'),
		    require => Package["NewRelic-RPM"]
    }

    service { "NewRelic-Sysmond":
        ensure     => $service_ensure,
        enable     => $service_enable,
        hasstatus  => true,
        hasrestart => true,
        subscribe  => File["nrsysmond.cfg"]
    }

    exec { "$license_key":
        path    => '/bin:/usr/bin',
        command => "/usr/sbin/nrsysmond-config --set license_key=${license_key}",
        user    => 'root',
        group   => 'root',
        unless  => "cat /etc/newrelic/nrsysmond.cfg | grep ${license_key}",
        require => Package["NewRelic-RPM"],
        notify  => Service["NewRelic-Sysmond"]
  }
}
