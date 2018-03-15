lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'slack-rtmapi/version'

Gem::Specification.new do |spec|
  spec.name          = 'slack-rtmapi'
  spec.version       = SlackRTM::VERSION
  spec.authors       = ['mackwic', 'Stefan - Zipkid - Goethals']
  spec.email         = ['mackwic@gmail.com', 'stefan@zipkid.eu']

  spec.summary = 'Naive wrapper for the Slack RTM api'
  spec.description = "slack-rtmapi is dumb: no EventMachine, no Celluloid, no Actor design pattern, no thread pool (thought, any of those
  would be trivial to add). It's a simple loop on top of a SSL socket with a websocket decoder. Minimal dependency. Works out of the box.
  Hackable. Composable. Oh, by the way, it implements very well the Slack API."
  spec.homepage = 'https://github.com/zipkid/slack-rtmapi'
  spec.license = 'GPLv3'

  raise 'RubyGems 2.0 or newer is required to protect against public gem pushes.' unless spec.respond_to?(:metadata)
  spec.metadata['allowed_push_host'] = 'http://rubygems.com'

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'

  spec.add_runtime_dependency 'websocket-driver'
end
