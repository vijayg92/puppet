class openresty($openresty_version=undef, $pcre_version=undef, $openresty_path=undef) {

    if ($openresty_path) {
        $openresty_path_real = $openresty_path
    }
    else {
        $openresty_path_real = '/opt/openresty'
    }

    if ($openresty_version) {
        $openresty_version_real = $openresty_version
    }
    else {
        $openresty_version_real = '1.11.2.3'
    }

    if ($pcre_version) {
        $pcre_version_real = $pcre_version
    }
    else {
        $pcre_version_real = '8.39'
    }

    $packagelist = ['readline-devel', 'wget', 'pcre-devel', 'openssl-devel', 'gcc', 'curl', 'gcc-c++', 'autoconf', 'automake']
    package { $packagelist:
        ensure => present
    }

    exec { "PCRE Setup":
        command => "wget --no-cache https://ftp.pcre.org/pub/pcre/pcre-${pcre_version_real}.tar.gz && tar -xvzf pcre-${pcre_version_real}.tar.gz",
        cwd     => '/tmp',
        creates => "/tmp/pcre-${pcre_version_real}/configure",
        require => Package['readline-devel', 'wget', 'pcre-devel', 'openssl-devel', 'gcc', 'curl', 'gcc-c++', 'autoconf', 'automake']
    }

    exec { "OpenResty Setup":
        command => "wget --no-cache https://openresty.org/download/openresty-${openresty_version_real}.tar.gz && tar -xvzf openresty-${openresty_version_real}.tar.gz",
        cwd     => '/tmp',
        creates => "/tmp/openresty-${openresty_version_real}/configure",
        require => Exec["PCRE Setup"]
    }

    exec { "OpenResty Installation":
        command => "bash -c './configure --prefix=${openresty_path_real} --with-pcre-jit --with-pcre=/tmp/pcre-${pcre_version_real} --with-luajit -j4 && gmake -j4 && gmake install'",
        cwd     => "/tmp/openresty-${openresty_version_real}",
        creates => [
        "/opt/openresty/nginx/sbin/nginx",
        "/opt/openresty/bin/resty",
        "/opt/openresty/nginx/conf/nginx.conf",
        "/opt/openresty/luajit/bin/luajit",
        "/opt/openresty/lualib/resty/core.lua"
        ],
        require => Exec["OpenResty Setup"]
    }

    file { "openresty-profile":
      ensure  => file,
      path    => "/etc/profile.d/openresty.sh",
      owner   => 'root',
      group   => 'root',
      mode    => '0755',
      require => Exec["OpenResty Installation"],
      content => template('openresty/openresty-profile.erb')
    }

    file { "openresty-nginx":
      ensure  => file,
      path    => "/etc/rc.d/init.d/openresty-nginx",
      owner   => 'root',
      group   => 'root',
      mode    => '0755',
      require => File["openresty-profile"],
      content => template('openresty/openresty-nginx.erb')
    }

    service { 'openresty-nginx':
          ensure     => running,
          enable     => true,
          hasstatus  => true,
          hasrestart => true,
          require    => File["openresty-nginx"]
      }
}
