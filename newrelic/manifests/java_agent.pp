define newrelic::java_agent(
			$license_key=undef,
			$app_name=undef,
			$app_root=undef,
			$app_user=undef,
			$app_group=undef,
			$app_start_path=undef,
			$app_stop_path=undef,
			$jvm_conf_path=undef
 	){

	if ! $license_key {
		fail("You must specify a valid License Key!!")
	}

	if ! $app_name {
		fail("Application name must be specified in order to configure NewRelic Java Agent!!")
	}

	if ! $app_root {
		fail("Application Root must be decalred in order to configure NewRelic Java Agent!!")
	}

	if ! $app_user {
		fail("Application User must be specified in order to configure NewRelic Java Agent!!")
	}

	if ! $app_group {
		fail("Application Group name must be specified in order to configure NewRelic Java Agent!!")
	}

	if ! $jvm_conf_path {
		fail("JVM conf file path must be specified in order to configure NewRelic Java Agent!!")
	}

	if ! $app_start_path {
		fail("Application startup path must be decalred in order to configure NewRelic Java Agent!!")
	}

	if ! $app_stop_path {
		fail("Application stop path must be decalred in order to configure NewRelic Java Agent!!")
	}

	#### Installation of Newrelic ####
	exec { "${app_name}-agent-install":
        command => "wget -N https://download.newrelic.com/newrelic/java-agent/newrelic-agent/current/newrelic-java.zip && unzip newrelic-java.zip -d ${app_root}",
        cwd     => "/tmp",
        creates => "${app_root}/newrelic/newrelic.jar",
        timeout => 0
    }

	#### Installation of Newrelic ####

	exec { "${app_name}-agent-config":
        #command => "sed -ie '45 a\ export JAVA_OPTS=${JAVA_OPTS} -javaagent:${app_root}/newrelic/newrelic.jar' ${app_root}/bin/catalina.sh",
				command => "echo 'export JAVA_OPTS=$JAVA_OPTS -javaagent:${app_root}/newrelic/newrelic.jar' >> ${jvm_conf_path}",
        cwd     => "/tmp",
        creates => "${app_root}/newrelic/newrelic.yml",
				require => Exec["${app_name}-agent-install"]
	}

	#### Application Changes ####
	file { "${app_name}-newrelic.yml":
        ensure  => file,
        path    => "${app_root}/newrelic/newrelic.yml",
        owner   => "${app_user}",
        group   => "${app_group}",
        mode    => "0755",
        content => template("newrelic/java/newrelic.yml.erb"),
				require => [ Exec["${app_name}-agent-install"], Exec["${app_name}-agent-config"] ]
    }

	#### Application Restart ####
	exec{"${app_name}-restart":
        command     => "${app_stop_path}; sleep 10; ${app_start_path}",
        refreshonly => true,
				require => [ Exec["${app_name}-agent-install"], Exec["${app_name}-agent-configure"] ]
	}
}
