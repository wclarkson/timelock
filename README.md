# Timelock

In "Time-lock puzzles and timed-release crypto", Rivest et al. describe a
method to encode information such that it can only be decrypted after a certain
amount of time has elapsed. In practice, this is implemented by requiring the
party decrypting the message to repeatedly square a value to obtain a key
with which the message can be decrypted. This operation is inherently
sequential and, without significant advances in prime factorization, cannot be
significantly parallelized.

## Usage
Run `timelock.rb` to get usage information. Try out encrypting and decrypting
a message like this:

      echo "hello world!" | ./timelock encrypt -t 10 | ./timelock.rb decrypt

The output of `timelock encrypt` is YAML, with numbers stored in base 16 and
ciphertext stored in base 64

    ---
    n: '0xd424561c0e58fc9627098068ef21c5db4647ed37e9b9f45809bb86ef7899ac11'
    t: '0x3b9aca'
    a: '0x7ca1d4221b246666310649c6ab3731c7d67779aca244fb5248dba5d2308df00'
    ck: '0x795d9a45afe7ae9297f7cf24ec29ebde72c40c627cf43c96c70a8573e7df7843'
    cm: |
      tjqVnMTCi6Jfr7A+3A==

