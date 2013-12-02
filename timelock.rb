#!/usr/bin/env ruby

require 'openssl'
require 'base64'
require 'yaml'
require 'optparse'
require 'benchmark'

class TimelockPuzzle
  def self.encrypt(plaintext, t)
    cipher = OpenSSL::Cipher::AES.new(128, :CFB)
    cipher.encrypt
    keystring = cipher.random_key
    key = hexstring_to_int(keystring)

    p       = OpenSSL::BN.generate_prime(128)
    q       = OpenSSL::BN.generate_prime(128)
    n       = p*q
    a       = OpenSSL::BN.new((Random.rand(n-2)+2).to_s)  # random in range 1 < a < n
    totient = (p-1)*(q-1)
    e       = OpenSSL::BN.new("2").mod_exp(OpenSSL::BN.new(t.to_s), totient)

    key %= n

#    puts "a = #{a}"
#    puts "e = #{e}"
#    puts "keynum = #{key}"
#    puts "key    = #{int_to_hexstring(key).inspect()}"

    b = OpenSSL::BN.new(a.to_s).mod_exp(e, n)
#    puts "b = #{b}"
    ck = (key + b) % n

    cipher.key = int_to_hexstring(key % n)
    cm = cipher.update(plaintext) + cipher.final

    yaml = {  "n"  => "0x%x" % n,
              "t"  => "0x%x" % t,
              "a"  => "0x%x" % a,
              "ck" => "0x%x" % ck,
              "cm" => Base64.encode64(cm) }
    return YAML.dump(yaml)
  end

  def self.decrypt(yaml)
#    puts "DECRYPTING"
    hash = YAML.load(yaml)
    n  = hash["n"].hex
    t  = hash["t"].hex
    a  = hash["a"].hex
    ck = hash["ck"].hex
    cm = Base64.decode64(hash["cm"])
#    puts "ck:%x" % ck
#    puts "a = #{a}, e = #{2**t}, mod = #{n}"
    b  = OpenSSL::BN.new(a.to_s).mod_exp(2**t, n)
#    puts "b = #{b}"
    k  = int_to_hexstring(ck - b)
#    puts "keystring = #{k.inspect()}"
#    puts "keynum    = #{ck-b}"

    cipher = OpenSSL::Cipher::AES.new(128, :CFB)
    cipher.decrypt
    cipher.key = k
    plaintext = cipher.update(cm) + cipher.final
    return plaintext
  end

  def self.benchmark(iter = 25)
    t0 = Time.now
    # these arbitrary values don't actually affect results that much
    OpenSSL::BN.new("7324129").mod_exp(2**iter, 83289)
    tf = Time.now
    return (tf-t0)/iter # seconds per squaring
  end

  def self.hexstring_to_int(str)
    return str.unpack("H*")[0].hex
  end
  
  def self.int_to_hexstring(int)
    return ["%x" % int].pack("H*")
  end

end

def time_test(time)
  rate = TimelockPuzzle.benchmark()
  iters = time / rate
  #puts "desired time: #{time}"
  t0 = Time.now
  puzzle = TimelockPuzzle.encrypt("hello world!", iters)
  t1 = Time.now
  #puts "creating puzzle: #{t1-t0}"
  t0 = Time.now
  TimelockPuzzle.decrypt(puzzle)
  t1 = Time.now
  puts "#{time}:\t #{t1-t0}"
end

#usage = <<EOS
#usage: #{ARGV[0]} <command> [<args>]
#
#EOS

#encrypt_parser = OptionsParser.new do |opts|
#  options = { :iters => 100, :out => STDOUT }
#  opts.on("-n", "--iterations") do |n|
#    options[:iters] = n
#  end
#  
#  opts.on("-o") do |out|
#    options[:out] = out
#  end
#
#  options
#end

#tl = TimelockPuzzle.encrypt("hello world!", 0)
#puts tl
#puts TimelockPuzzle.decrypt(tl).inspect()

(1..5).each do |time|
  4.times do
    time_test(time)
  end
end
