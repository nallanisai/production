require 'spec_helper'
describe 'tools' do
  context 'with default values for all parameters' do
    it { should contain_class('tools') }
  end
end
