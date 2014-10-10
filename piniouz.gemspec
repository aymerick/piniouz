require File.join(File.dirname(__FILE__), 'lib', 'piniouz', 'version')

spec = Gem::Specification.new do |s|
  s.name        = "piniouz"
  s.version     = Piniouz::VERSION
  s.platform    = Gem::Platform::RUBY
  s.summary     = "Piniouz"
  s.description = <<-EOF
  Creating weekly newsletters with pinboard and mailchimp.
  EOF

  s.author   = "Aymerick JEHANNE"
  s.homepage = "https://github.com/aymerick/piniouz"

  s.require_paths = [ "lib" ]
  s.bindir        = "bin"
  s.executables   = %w( piniouz )
  s.files         = %w( LICENSE Rakefile README.md ) + Dir["{bin,lib}/**/*"]

  s.add_dependency("toml")
  s.add_dependency("pinboard")
  s.add_dependency("mustache")
  s.add_dependency("gibbon")
  s.add_dependency("launchy")
end
