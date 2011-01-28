require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Sifar, 'when testing for minimum length' do
  it 'accepts words equal or bigger than given length' do
    checker = Sifar.new :minimum_length => 8

    checker.check(password(8)).should == true
    checker.check(password(10)).should == true
  end

  it 'rejects words smaller than given length' do
    checker = Sifar.new :minimum_length => 8

    checker.check(password(7)).should == false
  end
end

describe Sifar, 'when testing for heterogeneity' do
  it 'accepts heterogeneous words' do
    checker = Sifar.new :heterogeneous => true

    checker.check('aA34zX9j').should == true
  end

  it 'rejects homogeneous words' do
    checker = Sifar.new :heterogeneous => true

    checker.check(password(10)).should == false
  end
end

describe Sifar, 'when testing for dictionary words' do
  it 'rejects words in dictionary' do
    word = password(10)

    temporary_file(word) do |dictionary|
      checker = Sifar.new :dictionary => dictionary
      checker.check(word).should == false
    end
  end

  it 'accepts words not in dictionary' do
    temporary_file('indictionary') do |dictionary|
      checker = Sifar.new :dictionary => dictionary
      checker.check('notindictionary').should == true
    end
  end
end

describe Sifar, 'when testing for blacklisted characters' do
  it 'rejects words with blacklisted characters' do
    checker = Sifar.new :character_blacklist => %w(& % $)
    checker.check('blacklisted&character').should == false
  end

  it 'accepts words without blacklisted characters' do
    checker = Sifar.new :character_blacklist => %w(& % $)
    checker.check('blacklistedcharacter').should == true
  end
end

describe Sifar, 'when testing for similar spelling' do
  it 'rejects words with similarity equal or more than the given threshold' do
    checker = Sifar.new :similarity => 1, :name => 'shoeman'
    checker.check('showman').should == false
    checker.check('anothershoeman').should == false
  end

  it 'accepts words with similarity less than the given threshold' do
    checker = Sifar.new :similarity => 1, :name => 'password'
    checker.check('pa55word').should == true
  end
end

describe Sifar, 'when testing for similar pronounciation' do
  it 'rejects words with phonetic similarity equal or more than the given threshold' do
    checker = Sifar.new :phonetic_similarity => 1, :name => 'suman'
    checker.check('showman').should == false
  end

  it 'accepts words with phonetic similarity less than the given threshold' do
    checker = Sifar.new :phonetic_similarity => 1, :name => 'password'
    checker.check('firstpassword').should == true
  end
end

describe Sifar, 'when generating passwords' do
  it 'passes all checks' do
    temporary_file('indictionary') do |dictionary|
      checks = {
        :minimum_length => 8,
        :dictionary => dictionary,
        :character_blacklist => %w(& % $),
        :phonetic_similarity => 2,
        :similarity => 2
      }

      c = checks.keys
      (1..c.size).each do |n|
        c.combination(n).each do |options|
          checker = Sifar.new checks.reject{|key, value| !options.include?(key)}.merge({:name => 'suman'})
          password = checker.generate
          checker.check(password).should == true
        end
      end
    end
  end
end