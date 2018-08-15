class jenkins {

     #Add the jenkins to the yum repo along the GPG key
     yumrepo { 'jenkins_repo':
              baseurl  => "http://pkg.jenkins-ci.org/redhat",
              descr    => "Jenkins",
              enabled  => 1,
              gpgcheck => 1,
              gpgkey   => "http://pkg.jenkins-ci.org/redhat/jenkins-ci.org.key",
            }

    #Ensure Java 8 is installed since Jenkins requires JRE v1.8+
    package { 'java8':
      name   => 'java-1.8.0-openjdk',
      ensure => installed,
    }

    #Install the jenkins package
    package { 'jenkins':
       ensure   => latest,
       #require  => Package['java8'],
    }

    #Alter /etc/sysconfig/jenkins and change the default JENKINS_PORT="8080" to JENKINS_PORT="8000"
    #Using the defined type file_line in the puppetlabs-stdlib module
    file_line { 'jenkins_port_line':
      ensure             =>  present,
      path               => '/etc/sysconfig/jenkins',
      line               => 'JENKINS_PORT="8000"',
      match              => '^JENKINS_PORT=',
      append_on_no_match => true,
    }

    #Create the service file for the jenkins service
    file {'/etc/systemd/system/jenkins.service':
    ensure   => file,
    source  => 'puppet:///modules/jenkins/jenkins.service',
    }

   #Start the jenkins service
   service{'jenkins':
    ensure    => running,
    enable    => true,
    }
  
   #Manage dependencies for all the the above 
   Yumrepo['jenkins_repo'] ~> Package['java8'] ~> Package['jenkins'] ~> File_line['jenkins_port_line'] ~> File['/etc/systemd/system/jenkins.service'] ~> Service['jenkins']
}
