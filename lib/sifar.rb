require 'rubygems'
require 'text'
require 'digest'

class Sifar
  attr_accessor :errors

  def initialize(options = {}, error_messages = {})
    set_opt options, error_messages
  end

  def check(word)
    @errors = []

    check_length(word) unless @options[:minimum_length].nil?
    check_dictionary(word) unless @options[:dictionary].nil?
    check_character_blacklist(word) unless @options[:character_blacklist].nil?
    check_phonetic(word, @options[:name]) unless @options[:phonetic_similarity].nil?
    check_similarity(word, @options[:name]) unless @options[:similarity].nil?

    check_heterogeneity(word) if true == @options[:heterogeneous]

    1 > @errors.length
  end

  def generate
    n = 0
    begin
      n += 1
      word = create
    end until true == check(word)
    word
  end

  private
  def create
    max = @options[:minimum_length] || 8
    seed = (0..max).map{|i| (32 + rand(126-32)).chr}.join
    Digest::SHA1.hexdigest(seed)[0..max]
  end

  def check_length(word)
    @errors << @error_messages[:length] if word.length < @options[:minimum_length].to_i
  end

  def check_heterogeneity(word)
    num_chars = word.length
    num = {}
    num[:upper] = word.gsub(/[^[:upper:]]/, '').length
    num[:lower] = word.gsub(/[^[:lower:]]/, '').length
    num[:digit] = word.gsub(/[^[:digit:]]/, '').length
    num[:special] = num_chars - (num[:upper] + num[:lower] + num[:digit])

    max = 4 > num_chars ? 3 : num_chars - 3
    num.each_value do |value|
      if value > max
        @errors << @error_messages[:heter]
        return false
      end
    end

    true
  end

  def check_dictionary(word)
    if File.readable? @options[:dictionary]
      @errors << @error_messages[:dict] if find_word_in_file(word, @options[:dictionary])
    else
      @errors << @error_messages[:config_blackword]
    end
  end

  def check_character_blacklist(word)
    pattern = /#{@options[:character_blacklist].map{|c| Regexp.escape c}.join('|')}/i
    @errors << @error_messages[:config_blackword] unless pattern.match(word).nil?
  end

  def check_phonetic(word, name)
    unless @options[:phonetic_similarity] < Text::Levenshtein.distance(Text::Metaphone.metaphone(word), Text::Metaphone.metaphone(name))
      @errors << @error_messages[:phonetic]
      return false
    end
    true
  end

  def check_similarity(word, name)
    longer, shorter = [word, name].sort{|x,y| y.size <=> x.size}
    unless !longer.include?(shorter) and @options[:similarity] < Text::Levenshtein.distance(longer, shorter)
      @errors << @error_messages[:similar]
      return false
    end
    true
  end

  def find_word_in_file(word, file)
    t = []
    IO.popen("#{@options[:grep_path]} -ixs '#{word}' #{file}") {|io|
      r = io.readlines
      t << r unless r.empty?
    }
    not t.empty?
  end

  def set_opt(options = {}, error_messages = {})
    @options = {
      :password_check_type => 'LD',
      :name_check_type => 'S',
      :error_msg_hash => {},
      :umlaut_hash => {},
      :grep_path => `which grep`.chomp
    }.merge options

    raise ArgumentError, 'grep not found' unless (File.stat(@options[:grep_path]).executable? rescue false)

    @error_messages = {
      :length => 'The password is too short!',
      :similar => 'The password is too similar to the given name!',
      :phonetic => 'The password sounds too similar to the given name!',
      :dict => 'The password is based upon a dictionary word!',
      :heter => 'The password is too homogeneous!',
      :blackword => 'The password is based upon a blacklsited word!',
      :blackchar => 'The password contains a blacklisted character!',
      :similar_looking_chars => 'The password contains  similar looking  characters!',
      :config_blackchar => 'Could not load a valid blacklisted character file!',
      :config_blackword => 'Could not load a valid blacklisted word file!',
      :config_dict => 'Could not load a valid dictionary file!',
      :config_heter => 'Conflict in heterogeneity check and password generation configuration!',
      :config_length => 'Generated password length cannot be less then specified minimum length!'
    }.merge error_messages
    @errors ||= []
  end
end
