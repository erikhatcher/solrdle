require 'uri'
require 'net/http'
require 'json'

def grade(guess, answer)
    scratch = answer.clone
    g = '?????'
    guess.chars.each_with_index { |c,i| 
      #puts "#{answer},#{c},#{i},#{g}"
      if c == scratch[i]
        g[i] = '^'
        scratch[i] = '#'
      else
        pos = scratch.index(c)
        if !pos 
          g[i] = 'x'
        end
      end
    }

    g.chars.each_with_index { |c,i| 
      if c == '?'
        pos = scratch.index(guess[i])
        if pos
          g[i] = '~'
          scratch[pos] = '#'
        else
          g[i] = 'x'
        end
      end
    }

    return g
  end

  def possible_matches(guesses_results)
    solr_fqs = []
    known_letters = []
    excluded_letters = []
    last_word = ''
    
    guesses_results.each { |arg|
      word = arg.split(' ')[0]
      word_info = arg.split(' ')[1]
    
      word_info.chars.each_with_index { |c,i| 
        letter = word[i]
        case c
          when '^' # exact position match
            solr_fqs << "letter#{i+1}_s:#{letter}"
            known_letters << letter
          when 'x' # letter not in solution
            solr_fqs << "-letter#{i+1}_s:#{letter}"
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
    solr_fqs << '-({!terms f=letters_ss v=$exclude_letters})'
    
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
    
    return solr_response['response']['docs'].collect {|doc| doc['id']}
  end

  def get_all_words
    uri = URI('http://localhost:8983/solr/words/select?q=*:*&wt=csv&csv.header=false&rows=9999&fl=id')
    res = Net::HTTP.get_response(uri)
    raise "HTTP Issue #{res.value}: #{res.message}" if !res.is_a?(Net::HTTPSuccess)
    return res.body.split
  end

  def get_wordle_words
    #from https://www.nytimes.com/games/wordle/index.html => window.wordle.hash = '7785bdf7'

    wordle_hash = '7785bdf7'
    uri = URI("https://www.nytimes.com/games/wordle/main.#{wordle_hash}.js")

    res = Net::HTTP.get_response(uri)
    raise "HTTP Issue #{res.value}: #{res.message}" if !res.is_a?(Net::HTTPSuccess)
    #puts res.body

    # var Ma=[ ... ]
    wordle_source_match = /var Ma\=\[(?<words>[^\]]*)\]/.match(res.body)

    wordle_source_match['words'].delete('"').upcase.split(',').sort
  end