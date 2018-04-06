require 'spec_helper'
describe 'netbrains' do
  context 'with default values for all parameters' do
    it { should contain_class('netbrains') }
  end
end
