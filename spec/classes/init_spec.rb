require 'spec_helper'
describe 'nfs_server' do
  context 'with default values for all parameters' do
    it { should contain_class('nfs_server') }
  end
end
