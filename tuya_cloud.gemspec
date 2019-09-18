
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
    {Tuya Cloud}[https://en.tuya.com/], without the need to flash custom firmware or 
    discover device keys.
    These devices are sold under many different brands internationally, and usually all have their own mobile
    apps (i.e. {Smart Life}[https://play.google.com/store/apps/details?id=com.tuya.smartlife],
    {Tuya Smart}[https://play.google.com/store/apps/details?id=com.tuya.smart] or 
    {Genio}[https://play.google.com/store/apps/details?id=com.mirabella.genio])
    If you're app looks something like the images 
    {here}[https://iotrant.com/2019/06/07/smart-home-apps-volume-11-tuya-smart/], chances are this library will 
    work for you.
    This Ruby implementation was based on work by {PaulAnnekov}[https://github.com/PaulAnnekov/tuyaha], using an
    endpoint specifically designed for {Home Assistant}[https://www.home-assistant.io/].
    The online devices which are supported at this stage are LED globes (white and colour) and mains switches,
    along with support for activating scenes you've created within the Tuya app.
  DESCEND
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  # if spec.respond_to?(:metadata)
  #   spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  #
  #   spec.metadata["homepage_uri"] = spec.homepage
  #   spec.metadata["source_code_uri"] = "TODO: Put your gem's public repo URL here."
  #   spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."
  # else
  #   raise "RubyGems 2.0 or newer is required to protect against " \
  #     "public gem pushes."
  # end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "webmock"
end
