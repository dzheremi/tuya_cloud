
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "tuya_cloud/version"

Gem::Specification.new do |spec|
  spec.name          = "tuya_cloud"
  spec.version       = TuyaCloud::VERSION
  spec.authors       = ["Jeremy Mercer"]
  spec.email         = ["dzheremi@outlook.com"]
  spec.homepage      = "https://github.com/dzheremi/tuya_cloud"
  spec.summary       = "TuyaCloud is a small Ruby gem to allow control of smart devices connected to the Tuya Cloud,"\
                       " without the need to flash customer firmware or discover device keys."
  spec.description   = <<-DESCEND
    TuyaCloud is a small Ruby gem to allow control of smart devices connected to the 
    Tuya Cloud, without the need to flash custom firmware or discover device keys.
    These devices are sold under many different brands internationally, and usually all have their own mobile
    apps (i.e. Smart Life, Tuya Smart or Genio).
    This Ruby implementation was based on work by PaulAnnekov (https://github.com/PaulAnnekov/tuyaha), using an
    endpoint specifically designed for Home Assistant.
    The online devices which are supported at this stage are LED globes (white and colour) and mains switches,
    along with support for activating scenes you've created within the Tuya app.
  DESCEND
  spec.license       = "MIT"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "webmock"
end
