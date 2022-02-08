# Usage: word_guesser "<word> <pattern>" ...
#     e.g. word_guesser "POWER ^xx~~"
#     where P is correct location, OW are not in solution, ER are correct but in wrong spots

require 'uri'
require 'net/http'
require 'json'
require 'pp'

solr_fqs = ['-({!terms f=letters_ss v=$exclude_letters})']
known_letters = []
excluded_letters = []
last_word = ''

ARGV.each { |arg|
  word = arg.split(' ')[0]
  word_info = arg.split(' ')[1]

  word_info.chars.each_with_index { |c,i| 
    letter = word[i]
    case c
      when '^' # exact position match
        solr_fqs << "letter#{i+1}_s:#{letter}"
        known_letters << letter
      when 'x' # letter not in solution
        excluded_letters << letter
      when '~' # letter in solution, not in this position
        solr_fqs << "-letter#{i+1}_s:#{letter}"
        known_letters << letter
      else
        raise "Unknown info character: #{c}"
      end

      last_word = word
  }
}

excluded_letters = excluded_letters - known_letters # account for duplicate letters with one excluded
solr_fqs << "letters_ss:(#{known_letters.join(' AND ')})" if known_letters.size > 0

solr_params = {
    guess: last_word,
    q: '*:*',
    rows: '9999',
    facet: 'on',
    'facet.mincount': '1',
    'facet.field': %w(letters_ss letter1_s letter2_s letter3_s letter4_s letter5_s),
    'facet.pivot': 'letter1_s,letter2_s,letter3_s,letter4_s,letter5_s',
    fl: 'id',
    exclude_letters: excluded_letters.join(','),
    fq: solr_fqs,
  }

  #puts solr_params

  uri = URI('http://localhost:8983/solr/words/select?' + URI.encode_www_form(solr_params))
  #puts uri
  res = Net::HTTP.get_response(uri)
  raise "HTTP Issue #{res.value}: #{res.message}" if !res.is_a?(Net::HTTPSuccess)
  solr_response = JSON.parse(res.body)

  puts solr_response['response']['docs'].collect {|doc| doc['id']}

  #puts solr_response


