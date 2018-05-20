class jenkins {

    #    include ::firewall

     #Add the jenkins to the yum repo along the GPG key
     yumrepo { 'jenkins_repo':
              baseurl  => "http://pkg.jenkins-ci.org/redhat",
              descr    => "Jenkins",
              enabled  => 1,
              gpgcheck => 1,
              gpgkey   => "http://pkg.jenkins-ci.org/redhat/jenkins-ci.org.key",
            }


    #Ensure the latest version of Java is installed since Jenkins requires JRE v1.8+
    package { 'java8':
      name   => 'java-1.8.0-openjdk',
      ensure => installed,
    }


    #Install the package jenkins
    package { 'jenkins':
       ensure   => latest,
       #require  => Package['java8'],
    }

    #Alter /etc/sysconfig/jenkins and change the default JENKINS_PORT="8080" to JENKINS_PORT="8000"
    #Using the defined type file_line in the stdlib
    file_line { 'jenkins_port_line':
      ensure             =>  present,
      path               => '/etc/sysconfig/jenkins',
      line               => 'JENKINS_PORT="8000"',
      match              => '^JENKINS_PORT=',
      append_on_no_match => false,
    }


    file {'/etc/systemd/system/jenkins.service':
    ensure   => file,
    source  => 'puppet:///modules/jenkins/jenkins.service',
    #source   =>  'file:///etc/jenkins/jenkins.service',

    }


   # package { 'iptables-services':
   # ensure  => installed,
  #}

#  Firewall {
#  require => Package['iptables-services']
#}

#include ::firewall

  #In case of any running firewalls, make sure port 8000 is open
/*if defined('::firewall') {
    ::firewall {
      '500 allow Jenkins inbound traffic':
        action => 'accept',
        state  => 'NEW',
        dport  => [8000],
        proto  => 'tcp',
    }
}
 */
   service{'jenkins':
    ensure    => running,
    enable    => true,
    }

    Yumrepo['jenkins_repo'] ~> Package['java8'] ~> Package['jenkins'] ~> File_line['jenkins_port_line'] ~> File['/etc/systemd/system/jenkins.service'] ~> Service['jenkins']
}
