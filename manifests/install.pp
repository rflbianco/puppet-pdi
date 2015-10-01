# == Define: pdi::install
#
# Defines a version of Pentaho Data Integration to be installed in the system.
# This modules provide a Define instead of a Class for flexibility. It may be
# more natural to have only a single version of PDI in a production environment.
# However, it is common to have a few versions of it in a developer environment.
#
# === Parameters
#
# [*install_root_path*]
#   The root path where PDI must be installed in your system. This is not the
#   actual installation path. The real installation path will be: 
#   ${install_root_path}/pdi/${version}.
#
# [*version*]
#   The PDI version to be installed. It only affects the path where application
#   is installed. There is no automatic URL resolution. The url parameter must
#   be set too.
#
# [*url*]
#   URL to PDI distribution ZIP file to be downloaded and installed. Probably
#   from Pentaho's Source Forge page 
#   (http://sourceforge.net/projects/pentaho/files/Data%20Integration).
#
# [*pdi_startup_version*]
#   The PDI version to install the custom startup scripts from PDI Startup
#   (https://github.com/instituto-stela/pdi-startup). As PDI Startup does not
#   matches 1:1 to PDI versions, it must be passed manually. If 'undef' it
#   does not install.
#
# [*pdi_startup_branch*]
#   The branch (version) from PDI Startup repository (git) to download the
#   custom scripts.
#
# === Examples
#
#  pdi::install {'pdi-5.4' :
#    version             => '5.4',
#    url                 => 'http://sourceforge.net/projects/pentaho/files/Data%20Integration/5.4/pdi-ce-5.4.0.1-130.zip/download',
#    pdi_startup_version => '5.4.x',
#    pdi_startup_branch  => 'develop'
#  }
#

define pdi::install (
  $install_root_path   = '/opt',
  $version             = '5.4',
  $url                 = 'http://sourceforge.net/projects/pentaho/files/Data%20Integration/5.4/pdi-ce-5.4.0.1-130.zip/download',
  $pdi_startup_version = undef,
  $pdi_startup_branch  = 'master'
) {
  include pdi::config
  include pdi::params

  $_installer_name = "pdi-installer-${version}.zip"
  $_installer_path = "/tmp/${_installer_name}"
  $_install_path   = "${install_root_path}/pdi/${version}"

  $onlyif          = "test ! -e ${_install_path}/spoon.sh"

  file { ["${install_root_path}/pdi", $_install_path]:
    ensure  => 'directory',
    mode    => '0664'
  }

  exec{ "download-pdi-${version}":
    command => "curl -s -L ${url} -o ${_installer_path}",
    path    => $pdi::params::path,
    cwd     => '/tmp',
    creates => $installer_path,
    onlyif  => $onlyif,
    require => [Package['curl']]
  }

  exec{ "install-pdi-${version}":
    command => "unzip -o ${_installer_path} -d ${_install_path} && mv ${_install_path}/data-integration/* ${_install_path} && rm -rf ${_install_path}/data-integration",
    path    => $pdi::params::path,
    creates => "${_install_path}/spoon.sh",
    cwd     => '/tmp',
    onlyif  => $onlyif,
    require => [
      Exec["download-pdi-${version}"],
      Package['unzip']
    ]
  }

  exec{ "chmod-pdi-${version}":
    command => "chmod +x ${_installer_path}/*.sh",
    path    => $pdi::params::path,
    cwd     => '/tmp',
    onlyif  => $onlyif,
    require => [Exec["install-pdi-${version}"]]
  }

  if $pdi_startup_version != undef {
    exec{ "install-pdi-startup-${version}":
      command => "curl -L https://github.com/instituto-stela/pdi-startup/raw/develop/install.sh | sh -s -- --version ${pdi_startup_version} --branch ${pdi_startup_branch}",
      path    => $pdi::params::path,
      cwd     => "${_install_path}",
      creates => "${_install_path}/ps-spoon.sh",
      require => [
        Exec["install-pdi-${version}"],
        Package['curl']
      ]
    }
  }
}
