require_relative 'lib'

site_word_list = get_wordle_words
orig_words = get_all_words

puts orig_words - site_word_list
