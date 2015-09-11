# == Class: pdi
#
# Installs the latest version of Pentaho Data Integration with default params.
#
# === Examples
#
#  include pdi
#
#  # or 
#
#  class{ 'pdi': }
#
class pdi {
  pdi::install{ 'latest': }
}
