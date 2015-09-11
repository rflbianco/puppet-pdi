require 'spec_helper'
describe 'pdi' do

  context 'with defaults for all parameters' do
    it { should contain_class('pdi') }
  end
end
