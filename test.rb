require_relative 'lib'
require 'pp'

site_word_list = get_wordle_words
orig_words = get_all_words

puts "DIFF: ", orig_words - site_word_list

#curl -u admin:ehpassword123 -X POST -H 'content-type: application/json' http://35.185.213.251:6764/api/apps/test1/index/temp --data-binary @solr_docs.json
#curl -u admin:ehpassword123 -X POST -H 'content-type: application/json' http://35.185.213.251:8764/api/apps/test1/index/test1?echo=false --data-binary @solr_docs.json

#curl -u admin:ehpassword123 -X POST -H 'content-type: application/json' http://35.185.213.251:6764/api/apps/products/index/solr --data-binary @solr_docs.json


# From https://github.com/martinvelez/ruby_ngrams/blob/master/lib/ruby_ngrams.rb
# This is an extension of Ruby's core String class.
# It add methods to extract a set of n-grams from a string.
# Typically, the most used set of n-grams are unigrams, bigrams, and trigrams; 
# sets of n-grams of length 1, 2, and 3, respectively.
class String

	# An n-gram is a sequence of units of text of length n, where those units are 
	# typically single characters or words delimited by space characters.
	# However, a token could also be a fixed length character sequence, strings 
	# with embedded spaces, etc. depending on the intended application.
	# Typically, n-grams are formed of contiguous tokens.
	#
	# This function splits the string into a set of n-grams. 
	# The default regex used tokenizes the string into characters.
	#
	# Regex Examples:
	#		// 			=> splits into characters
	#		/\s+/ 	=> splits into words delimited by one or more space characters
	#		/\n+/ => splits into lines delimted by one or more newline characters
	#
	# TODO: Determine efficiency of this function on long strings.
	# TODO: Determine how well this works on strings in binary format.
	def ngrams(options = {:regex=>//, :n=>2})
		ngrams = []
		tokens = self.split(options[:regex])
		max_pos = tokens.length - options[:n]
		for i in 0..max_pos
			ngrams.push(tokens[i..i+(options[:n]-1)])
		end
		ngrams
	end
	
	# This function splits the string into unigrams,
	# tokenizes into chars by default
	def unigrams(regex = //) ngrams({:regex => regex, :n => 1}); end
	
	# This function splits the string into bigrams
	# tokenizes into chars by default
	def bigrams(regex = //) ngrams({:regex => regex, :n => 2}); end
	
	# This function splits the string into trigrams
	# tokenizes into chars by default
	def trigrams(regex = //) ngrams({:regex => regex, :n => 3}); end

end #class String

pp "PATCH".ngrams({:regex => //, :n => 3})

word = "PATCH"
fours = word.chars.each_with_index.collect { |c,i|
    w = word.clone 
    w[i] = '_'
    w
}

puts fours