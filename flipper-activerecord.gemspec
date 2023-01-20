# -*- encoding: utf-8 -*-
Gem::Specification.new do |gem|
  gem.name          = "flipper-activerecord"
  gem.version       = "1.0.0"
  gem.authors       = ["Blake Gentry"]
  gem.email         = ["blakesgentry@gmail.com"]
  gem.description   = %q{DEPRECATED: use the official flipper-active_record adapter}
  gem.summary       = %q{DEPRECATED: use the official flipper-active_record adapter}
  gem.homepage      = "https://github.com/bgentry/flipper-activerecord"
  gem.require_paths = ["lib"]

  separator = "*"*80
  gem.post_install_message = "\n\n#{separator}\nflipper-activerecord is deprecated. Use flipper-active_record instead.\n#{separator}\n\n"

  gem.files         = `git ls-files`.split($/)
end
