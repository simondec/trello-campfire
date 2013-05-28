Gem::Specification.new do |s|
  s.name        = 'trello-campfire'
  s.version     = File.exist?('VERSION') ? File.read('VERSION') : ''
  s.authors     = ['Simon de Carufel']
  s.email       = ['sdc@simondecarufel.com']
  s.homepage    = 'https://github.com/simondec/trello-campfire'
  s.summary     = 'Parse Trello activity feed into campfire'
  s.description = 'Parse Trello activity feed into campfire'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib']

  s.add_dependency 'rest-client', '~> 1.6.7'
  s.add_dependency 'tinder', '~> 1.9.2'
  s.add_dependency 'daemons', '~> 1.1.8'
  s.add_dependency 'trollop', '~> 2.0.0'
end
