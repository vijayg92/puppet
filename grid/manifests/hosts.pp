define grid::hosts($hostname=undef, $apps=undef,$big_ip=undef) {
if ($hostname) {
        $hostname_real = $hostname
    }
else {
        exit 0
 }
if ($apps) {
        $apps_real = $apps
    }
else {
        exit 0
 }
if ($big_ip) {
        $bigip_real = $big_ip
    }
else {
        exit 0
 }
file { "${hostname}-grid.html":
		ensure  => file,
        path    => "/appl/stats/$apps/$env/$hostname-grid.html",
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        #require => File["/appl/stat/webdocs"],
        content => template("grid/${apps}/${env}/$hostname-grid.html.erb")
	}	

}