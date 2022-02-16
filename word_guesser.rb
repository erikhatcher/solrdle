# Usage: word_guesser "<word> <pattern>" ...
#     e.g. word_guesser "POWER ^xx~~"
#     where P is correct location, OW are not in solution, ER are correct but in wrong spots

require_relative 'lib'

puts possible_matches(ARGV)



