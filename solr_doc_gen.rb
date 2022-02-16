require_relative 'lib'

word_list = get_wordle_words

solr_docs = []

word_list.each do |word|  
  solr_doc = { id: word.strip, 
               letter1_s: word[0],
               letter2_s: word[1],
               letter3_s: word[2],
               letter4_s: word[3],
               letter5_s: word[4],
               letters_ss: word.chars
             }
  solr_docs << solr_doc
end

puts JSON.dump(solr_docs)
