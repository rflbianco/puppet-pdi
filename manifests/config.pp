# == Class: pdi::config
# 
# Ensure all packages needed to execute installation are available on system.
# Especially for Docker containers and other striped down systems.
#
class pdi::config {
  case $::kernel {
    'Linux': {
      include pdi::config::linux
    }
    default: {
      fail("The kernel '${::kernel}' is not supported yet.")	
    }
  }
}