
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "be_valid/version"

Gem::Specification.new do |spec|
  spec.name          = "be_valid"
  spec.version       = BeValid::VERSION
  spec.authors       = ["John Stewart (johnsinco)"]

  spec.summary       = %q{Custom Ruby on Rails Validation library supporting 'conditional' validation}
  spec.description   = %q{Provides more advanced and flexible 'if then then that' style conditional validation. Validate fields based on the values of other fields in your model.}
  spec.homepage      = "https://github.com/johnsinco/be_then"
  spec.license       = "MIT"


  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.required_ruby_version = '>= 2.3'

  spec.add_development_dependency "bundler", "~> 1.17"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "activerecord", "~> 5"
  spec.add_development_dependency "sqlite3", "~> 1.4"
end
