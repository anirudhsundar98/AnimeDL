Gem::Specification.new do |spec|
  spec.name          = "AnimeDL"
  spec.version       = "0.2.1"
  spec.authors       = ["Anirudh Sundar"]
  spec.email         = "anirudhsundar@hotmail.com"

  spec.summary       = %q{The AnimeDL gem is used to get episode links or download episodes for a particular anime}
  spec.homepage      = "https://github.com/anirudhsundar98/AnimeDL"
  spec.license       = "MIT"

  spec.require_paths = ["lib"]
  spec.files         = `git ls-files`.split("\n")
  spec.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }

  spec.add_runtime_dependency 'mechanize', '~> 2.7'
  spec.add_runtime_dependency 'ruby-progressbar', '~> 1.8'
end