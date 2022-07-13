require_relative 'lib'

all_words = get_all_words()

answer = "#{ARGV[0]}" #all_words[rand(all_words.length)]
guess = all_words[rand(all_words.length)]
grade = grade(guess,answer)

puts "#{answer} :"

guesses_results = ["#{guess} #{grade}"]

puts guesses_results

matches = possible_matches(guesses_results)

while (matches.size != 1) do
  #puts matches

  guess = matches[rand(matches.length)]
  grade = grade(guess,answer)

  guesses_results << "#{guess} #{grade}"
  puts guesses_results.collect{|s| "\"#{s}\""}.join(' ')

  matches = possible_matches(guesses_results)
end

if grade != '^^^^^' 
  guesses_results << "#{answer} ^^^^^"
end

puts "  Solved in #{guesses_results.size} guesses"


