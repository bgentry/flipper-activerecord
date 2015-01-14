require 'set'
require 'flipper'
require 'active_record'

require 'flipper/activerecord/feature'
require 'flipper/activerecord/gate'

module Flipper
  module Adapters
    class ActiveRecord
      include Flipper::Adapter

      # Public: The name of the adapter.
      attr_reader :name

      def initialize
        @name = :activerecord
      end

      # Public: The set of known features.
      def features
        Flipper::ActiveRecord::Feature.select(:name).map(&:name).to_set
      end

      # Public: Adds a feature to the set of known features.
      def add(feature)
        opts = { name: feature.name.to_s }
        Flipper::ActiveRecord::Feature.where(opts).first ||
          Flipper::ActiveRecord::Feature.create!(opts)
        true
      end

      # Public: Removes a feature from the set of known features.
      def remove(feature)
        clear(feature)
      end

      # Public: Clears all the gate values for a feature.
      def clear(feature)
        Flipper::ActiveRecord::Feature.where(name: feature.key).destroy_all
        true
      end

      # Public: Gets the values for all gates for a given feature.
      #
      # Returns a Hash of Flipper::Gate#key => value.
      def get(feature)
        result = {}
        f = Flipper::ActiveRecord::Feature.eager_load(:gates).where(name: feature.key).first

        feature.gates.each do |gate|
          result[gate.key] = case gate.data_type
          when :boolean, :integer
            if f
              g = f.gates.detect {|g| g.name == gate.key.to_s}
              g.value if g
            end
          when :set
            if f
              f.gates.select {|g| g.name == gate.key.to_s}.map{|g| g.value }.to_set
            else
              Set.new
            end
          else
            unsupported_data_type gate.data_type
          end
        end

        result
      end

      # Public: Enables a gate for a given thing.
      #
      # feature - The Flipper::Feature for the gate.
      # gate - The Flipper::Gate to disable.
      # thing - The Flipper::Type being disabled for the gate.
      #
      # Returns true.
      def enable(feature, gate, thing)
        case gate.data_type
        when :boolean, :integer
          g = gate_join( feature )
          opts = { name: gate.key.to_s }
          g = g.where(opts).first || g.new(opts)
          g.value = thing.value.to_s
          unless g.persisted?
            g.feature = feature_id( feature )
          end
          g.save!
        when :set
          g = gate_join( feature )
          opts = { name:  gate.key.to_s, value: thing.value.to_s }
          g = g.where(opts).first || g.new!(opts)
          unless g.persisted?
            g.feature = feature_id( feature )
          end
          g.save!
        else
          unsupported_data_type gate.data_type
        end

        true
      end

      # Public: Disables a gate for a given thing.
      #
      # feature - The Flipper::Feature for the gate.
      # gate - The Flipper::Gate to disable.
      # thing - The Flipper::Type being disabled for the gate.
      #
      # Returns true.
      def disable(feature, gate, thing)
        scope = Flipper::ActiveRecord::Gate.joins(:feature).where(flipper_features: {name: feature.key})

        g = case gate.data_type
        when :boolean
          scope.destroy_all
        when :integer
          scope.where(name: gate.key.to_s).limit(1).
            update_all(value: thing.value.to_s)
        when :set
          scope.where(name: gate.key.to_s, value: thing.value.to_s).destroy_all
        else
          unsupported_data_type gate.data_type
        end

        true
      end
      
      # Private
      def feature_id( feature )
        opts = { name: feature.key }
        i = Flipper::ActiveRecord::Feature.select(:id)
        i.where(opts).first || i.create!(opts)
      end
      
      # Private
      def gate_join( feature )
        Flipper::ActiveRecord::Gate.joins(:feature).where( flipper_features: {name: feature.key} )
      end

      # Private
      def unsupported_data_type(data_type)
        raise "#{data_type} is not supported by this adapter"
      end

    end
  end
end
