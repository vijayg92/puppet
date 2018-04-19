class grid($env=undef, $app_name=undef ) {
if !($env in ['dev', 'stage', 'prod']) {
        fail('Grid env parameter must be dev, stage, or prod')
    }
if ($app_name) {
        $appname_real = $app_name
    }
else {
        exit 0
 }
file { "/appl/stat":
        ensure  => directory,
        path    => "/appl/stat",
        owner   => 'root',
        group   => 'root',
        mode    => '0775',
        recurse => true
 }

file { "/appl/stat/webdocs":
        ensure  => directory,
        path    => "/appl/stat/webdocs",
        owner   => 'root',
        group   => 'root',
        mode    => '0775',
        recurse => true,
		require => File["/appl/stat"]
    }
file { "/appl/stat/script":
        ensure  => directory,
        path    => "/appl/elastic/script",
        owner   => 'root',
        group   => 'root',
        mode    => '0775',
        recurse => true
		require => File["/appl/stat"]
    }

}
