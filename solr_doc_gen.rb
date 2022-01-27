require 'json'
file='five_letter_words.txt'
# puts 'id,letter1_s,letter2_s,letter3_s,letter4_s,letter5_s,letters_s'
solr_docs = []
File.readlines(file).each do |line|

  word = line.strip.upcase
  
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