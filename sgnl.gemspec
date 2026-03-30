# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name          = "sgnl"
  spec.version       = "0.3.0"
  spec.authors       = ["sgnl.sh"]
  spec.email         = ["support@sgnl.sh"]

  spec.summary       = "Observability for vibe coders"
  spec.description   = "Drop-in error tracking, slow request detection, and usage signals for Rails apps. AI-generated fix prompts in your dashboard."
  spec.homepage      = "https://sgnl.sh"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 3.1"

  spec.files = Dir["lib/**/*", "LICENSE", "README.md"]
  spec.require_paths = ["lib"]

  spec.add_dependency "railties", ">= 7.0"
end
