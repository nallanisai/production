require 'spec_helper'
describe 'tree' do
  context 'with default values for all parameters' do
    it { should contain_class('tree') }
  end
end
