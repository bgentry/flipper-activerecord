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

      def initialize(collection)
        @collection = collection
        @name = :activerecord
      end

      # Public: The set of known features.
      def features
        Flipper::ActiveRecord::Feature.select(:name).map(&:name).to_set
      end

      # Public: Adds a feature to the set of known features.
      def add(feature)
        Flipper::ActiveRecord::Feature.create!(name: feature.name.to_s)
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
        f = Flipper::ActiveRecord::Feature.find_by(name: feature.key)

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
        f = Flipper::ActiveRecord::Feature.find_or_create_by(name: feature.key.to_s)
        f.gates.find_or_create_by!(name: gate.key.to_s, value: thing.value.to_s)
        true
#         case gate.data_type
#         when :boolean, :integer
#           update feature.key, '$set' => {
#             gate.key.to_s => thing.value.to_s,
#           }
#         when :set
#           update feature.key, '$addToSet' => {
#             gate.key.to_s => thing.value.to_s,
#           }
#         else
#           unsupported_data_type gate.data_type
#         end
# 
#         true
      end

      # Public: Disables a gate for a given thing.
      #
      # feature - The Flipper::Feature for the gate.
      # gate - The Flipper::Gate to disable.
      # thing - The Flipper::Type being disabled for the gate.
      #
      # Returns true.
      def disable(feature, gate, thing)
        conditions = { flipper_features: {name: feature.key} }

        g = case gate.data_type
        when :boolean
          Flipper::ActiveRecord::Gate.joins(:feature).where(conditions).destroy_all
        when :integer
          conditions.merge!(name: gate.key.to_s)
          Flipper::ActiveRecord::Gate.joins(:feature).where(conditions).
            limit(1).update_all(value: thing.value.to_s)
        when :set
          conditions.merge!(name: gate.key.to_s, value: thing.value.to_s)
          Flipper::ActiveRecord::Gate.joins(:feature).where(conditions).destroy_all
        else
          unsupported_data_type gate.data_type
        end

        true
      end

      # Private
      def unsupported_data_type(data_type)
        raise "#{data_type} is not supported by this adapter"
      end

      # Private
      def find(key)
        @collection.find_one(criteria(key)) || {}
      end

      # Private
      def update(key, updates)
        options = {:upsert => true}
        @collection.update criteria(key), updates, options
      end

      # Private
      def delete(key)
        @collection.remove criteria(key)
      end

      # Private
      def criteria(key)
        {:_id => key.to_s}
      end
    end
  end
end
