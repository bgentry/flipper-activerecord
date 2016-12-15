# Flipper ActiveRecord

An [ActiveRecord](https://github.com/rails/rails/tree/master/activerecord) adapter for [Flipper](https://github.com/jnunemaker/flipper).

## Deprecated

The [Flipper](https://github.com/jnunemaker/flipper) project now includes its own ActiveRecord and Sequel adapters. It is recommended that all users migrate to the first-party adapter as I will not be supporting my own version any longer.

## Info

Currently, this targets Rails 4.2 because it uses real foreign keys via
`add_foreign_key` and `remove_foreign_key`. 

For users requiring Rails 3.2 support, please see: [Flipper ActiveRecord 3.2](https://github.com/blueboxjesse/flipper-activerecord).

## Installation

Add this line to your application's Gemfile:

    gem 'flipper-activerecord'

And then execute:

    $ bundle

Or install it yourself with:

    $ gem install flipper-activerecord

Generate a migration to create the required database tables:

    $ rails g flipper:active_record

## Usage

```ruby
require 'flipper/adapters/activerecord'
adapter = Flipper::Adapters::ActiveRecord.new
flipper = Flipper.new(adapter)
# profit...
```

## Internals

Two database tables are used: `flipper_features` and `flipper_gates`.

A list of all available features is stored in the `flipper_features` table:

```ruby
require 'flipper/adapters/activerecord'

adapter = Flipper::Adapters::ActiveRecord.new
flipper = Flipper.new(adapter)

# Register a few groups.
Flipper.register(:admins) { |thing| thing.admin? }
Flipper.register(:early_access) { |thing| thing.early_access? }

# Create a user class that has flipper_id instance method.
User = Struct.new(:flipper_id)

flipper[:stats].enable
flipper[:stats].enable flipper.group(:admins)
flipper[:stats].enable User.new('25')
flipper[:stats].enable User.new('90')
flipper[:stats].enable User.new('180')
flipper[:stats].enable flipper.random(15)
flipper[:stats].enable flipper.actors(45)

flipper[:awesomeness].enable
flipper[:awesomeness].enable flipper.group(:admins)


print 'all features: '
pp Flipper::ActiveRecord::Feature.all
#   Flipper::ActiveRecord::Feature Load (0.3ms)  SELECT "flipper_features".* FROM "flipper_features"
# [#<Flipper::ActiveRecord::Feature:0x007fa883c6b578
#   id: 1,
#   name: "stats",
#   created_at: Wed, 08 Oct 2014 07:21:27 UTC +00:00,
#   updated_at: Wed, 08 Oct 2014 07:21:27 UTC +00:00>,
#  #<Flipper::ActiveRecord::Feature:0x007fa883c6ada8
#   id: 2,
#   name: "awesomeness",
#   created_at: Wed, 08 Oct 2014 07:21:38 UTC +00:00,
#   updated_at: Wed, 08 Oct 2014 07:21:38 UTC +00:00>]

print 'all gates: '
pp Flipper::ActiveRecord::Gate.all
#   Flipper::ActiveRecord::Gate Load (0.4ms)  SELECT "flipper_gates".* FROM "flipper_gates"
# [#<Flipper::ActiveRecord::Gate:0x007fa883c42ab0
#   id: 1,
#   flipper_feature_id: 1,
#   name: "boolean",
#   value: "true",
#   created_at: Wed, 08 Oct 2014 07:21:27 UTC +00:00,
#   updated_at: Wed, 08 Oct 2014 07:21:27 UTC +00:00>,
#  #<Flipper::ActiveRecord::Gate:0x007fa883c42290
#   id: 2,
#   flipper_feature_id: 1,
#   name: "groups",
#   value: "admins",
#   created_at: Wed, 08 Oct 2014 07:21:31 UTC +00:00,
#   updated_at: Wed, 08 Oct 2014 07:21:31 UTC +00:00>,
#  #<Flipper::ActiveRecord::Gate:0x007fa883c41b10
#   id: 3,
#   flipper_feature_id: 1,
#   name: "actors",
#   value: "25",
#   created_at: Wed, 08 Oct 2014 07:21:31 UTC +00:00,
#   updated_at: Wed, 08 Oct 2014 07:21:31 UTC +00:00>,
#  #<Flipper::ActiveRecord::Gate:0x007fa883c41408
#   id: 4,
#   flipper_feature_id: 1,
#   name: "actors",
#   value: "90",
#   created_at: Wed, 08 Oct 2014 07:21:31 UTC +00:00,
#   updated_at: Wed, 08 Oct 2014 07:21:31 UTC +00:00>,
#  #<Flipper::ActiveRecord::Gate:0x007fa883c40c38
#   id: 5,
#   flipper_feature_id: 1,
#   name: "actors",
#   value: "180",
#   created_at: Wed, 08 Oct 2014 07:21:31 UTC +00:00,
#   updated_at: Wed, 08 Oct 2014 07:21:31 UTC +00:00>,
#  #<Flipper::ActiveRecord::Gate:0x007fa883c40558
#   id: 6,
#   flipper_feature_id: 1,
#   name: "percentage_of_random",
#   value: "15",
#   created_at: Wed, 08 Oct 2014 07:21:38 UTC +00:00,
#   updated_at: Wed, 08 Oct 2014 07:21:38 UTC +00:00>,
#  #<Flipper::ActiveRecord::Gate:0x007fa883c3bda0
#   id: 7,
#   flipper_feature_id: 1,
#   name: "percentage_of_actors",
#   value: "45",
#   created_at: Wed, 08 Oct 2014 07:21:38 UTC +00:00,
#   updated_at: Wed, 08 Oct 2014 07:21:38 UTC +00:00>,
#  #<Flipper::ActiveRecord::Gate:0x007fa883c3b5f8
#   id: 8,
#   flipper_feature_id: 2,
#   name: "boolean",
#   value: "true",
#   created_at: Wed, 08 Oct 2014 07:21:38 UTC +00:00,
#   updated_at: Wed, 08 Oct 2014 07:21:38 UTC +00:00>,
#  #<Flipper::ActiveRecord::Gate:0x007fa883c3afe0
#   id: 9,
#   flipper_feature_id: 2,
#   name: "groups",
#   value: "admins",
#   created_at: Wed, 08 Oct 2014 07:21:39 UTC +00:00,
#   updated_at: Wed, 08 Oct 2014 07:21:39 UTC +00:00>]

puts 'flipper get of feature'
pp adapter.get(flipper[:stats])
# flipper get of feature
#   SQL (0.6ms)  SELECT  DISTINCT "flipper_features"."id" FROM "flipper_features" LEFT OUTER JOIN "flipper_gates" ON "flipper_gates"."flipper_feature_id" = "flipper_features"."id" WHERE "flipper_features"."name" = $1 LIMIT 1  [["name", "stats"]]
#   SQL (0.3ms)  SELECT "flipper_features"."id" AS t0_r0, "flipper_features"."name" AS t0_r1, "flipper_features"."created_at" AS t0_r2, "flipper_features"."updated_at" AS t0_r3, "flipper_gates"."id" AS t1_r0, "flipper_gates"."flipper_feature_id" AS t1_r1, "flipper_gates"."name" AS t1_r2, "flipper_gates"."value" AS t1_r3, "flipper_gates"."created_at" AS t1_r4, "flipper_gates"."updated_at" AS t1_r5 FROM "flipper_features" LEFT OUTER JOIN "flipper_gates" ON "flipper_gates"."flipper_feature_id" = "flipper_features"."id" WHERE "flipper_features"."name" = $1 AND "flipper_features"."id" IN (1)  [["name", "stats"]]
# {:boolean=>"true",
#  :groups=>#<Set: {"admins"}>,
#  :actors=>#<Set: {"25", "90", "180"}>,
#  :percentage_of_actors=>"45",
#  :percentage_of_random=>"15"}
```

## Testing

```
dbcreate flipper_activerecord_test
rspec
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Thanks

Thanks to John Nunemaker for making Flipper and its adapters!
