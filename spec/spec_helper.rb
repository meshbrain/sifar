$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'rspec'
require 'sifar'
require 'tmpdir'

module SifarHelperMethods
    def password(num)
        (0...num).map{ ('a'..'z').to_a[rand(26)] }.join
    end

    def temporary_file(text, &block)
        temp_file = File.join(Dir.tmpdir, 'sifar_temporary_file')
        open(temp_file, 'w'){ |f| f.write text }
        block.call temp_file
        File.delete temp_file
    end
end

RSpec.configure do |config|
    config.before(:each) {}
    include SifarHelperMethods
end