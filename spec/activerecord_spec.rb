require 'helper'
require 'flipper/adapters/activerecord'
require 'flipper/spec/shared_adapter_specs'

describe Flipper::Adapters::ActiveRecord do
  let(:pool) { ActiveRecord::Base.connection_pool }
#     Que.connection = ::ActiveRecord if defined? ::ActiveRecord

  subject { described_class.new(pool) }

  it_should_behave_like 'a flipper adapter'
end
