require 'helper'
require 'flipper/adapters/activerecord'
require 'flipper/spec/shared_adapter_specs'

describe Flipper::Adapters::ActiveRecord do
  subject { described_class.new }

  it_should_behave_like 'a flipper adapter'
end
