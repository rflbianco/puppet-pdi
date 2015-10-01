# == Class: pdi::config::linux
# 
# Ensure all packages needed to execute installation are available on system.
# Especially for Docker containers and other striped down systems.
#
class pdi::config::linux {
  if ! defined(Package['curl']) {
    package { 'curl':
      ensure => present,
    }
  }

  if ! defined(Package['unzip']) {
    package { 'unzip':
      ensure => present,
    }
  }
}
