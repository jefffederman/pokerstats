# Generated by jeweler
# DO NOT EDIT THIS FILE
# Instead, edit Jeweler::Tasks in Rakefile, and run `rake gemspec`
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{pokerstats}
  s.version = "0.4.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Andrew C. Greenberg"]
  s.date = %q{2009-08-21}
  s.description = %q{a library for extracting, computing and reporting statistics of poker hands parsed from hand history files}
  s.email = %q{wizardwerdna@gmail.com}
  s.extra_rdoc_files = [
    "LICENSE",
     "README.rdoc"
  ]
  s.files = [
    ".document",
     ".gitignore",
     "LICENSE",
     "README.rdoc",
     "Rakefile",
     "VERSION",
     "lib/checkps",
     "lib/pokerstats.rb",
     "lib/pokerstats/.gitignore",
     "lib/pokerstats/hand_constants.rb",
     "lib/pokerstats/hand_history.rb",
     "lib/pokerstats/hand_statistics.rb",
     "lib/pokerstats/hand_statistics_api.rb",
     "lib/pokerstats/player_statistics.rb",
     "lib/pokerstats/plugins/aggression_statistics.rb",
     "lib/pokerstats/plugins/blind_attack_statistics.rb",
     "lib/pokerstats/plugins/cash_statistics.rb",
     "lib/pokerstats/plugins/continuation_bet_statistics.rb",
     "lib/pokerstats/plugins/preflop_raise_statistics.rb",
     "lib/pokerstats/poker-edge.rb",
     "lib/pokerstats/pokerstars_file.rb",
     "lib/pokerstats/pokerstars_hand_history_parser.rb",
     "pokerstats.gemspec",
     "spec/file_empty.txt",
     "spec/file_many_hands.txt",
     "spec/file_one_hand.txt",
     "spec/hand_statistics_spec.rb",
     "spec/hand_statistics_spec_helper.rb",
     "spec/player_statistics_spec.rb",
     "spec/pokerstars_file_spec.rb",
     "spec/pokerstars_hand_history_parser.rb",
     "spec/spec_helper.rb",
     "spec/zpokerstars_hand_history_parser_integration.txt"
  ]
  s.homepage = %q{http://github.com/wizardwerdna/pokerstats}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{poker hand history statistics library}
  s.test_files = [
    "spec/hand_statistics_spec.rb",
     "spec/hand_statistics_spec_helper.rb",
     "spec/player_statistics_spec.rb",
     "spec/pokerstars_file_spec.rb",
     "spec/pokerstars_hand_history_parser.rb",
     "spec/spec_helper.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rspec>, [">= 0"])
      s.add_development_dependency(%q<wizardwerdna-pluggable>, [">= 0"])
      s.add_runtime_dependency(%q<wizardwerdna-pluggable>, [">= 0"])
    else
      s.add_dependency(%q<rspec>, [">= 0"])
      s.add_dependency(%q<wizardwerdna-pluggable>, [">= 0"])
      s.add_dependency(%q<wizardwerdna-pluggable>, [">= 0"])
    end
  else
    s.add_dependency(%q<rspec>, [">= 0"])
    s.add_dependency(%q<wizardwerdna-pluggable>, [">= 0"])
    s.add_dependency(%q<wizardwerdna-pluggable>, [">= 0"])
  end
end