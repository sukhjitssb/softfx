lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

# Maintain your gem's version:
require "peatio/softfx/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name        = "peatio-softfx"
  spec.version     = Peatio::Softfx::VERSION
  spec.authors     = ["Sukhjit Singh Badwal"]
  spec.email       = ["sukhjitsingh.badwal@antiersolutions.com"]
  spec.homepage    = "https://openware.com/"
  spec.summary     = %q{Gem for extending Peatio plugable system with Soft-fx implementation.}
  spec.description = %q{Soft-fx Peatio gem which implements Peatio::Blockchain::Abstract & Peatio::Wallet::Abstract.}
  spec.license     = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "activesupport", "~> 6.1.0"
  spec.add_dependency "faraday", "~> 1.10"
  spec.add_dependency "peatio", ">= 3.1.1"
  spec.add_dependency 'net-http-persistent', '~> 4.0.1'

  spec.add_development_dependency "bundler", "~> 2.1.4"
  spec.add_development_dependency "pry-byebug"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "webmock", "~> 3.5"

end
