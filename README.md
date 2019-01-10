# fincher

fincher is steganography tool for text. It provides a number of strategies for
hiding a message within a source text by storing each character as a typo.

The method by which it works is contigent upon the combination of replacement
and displacement strategy. See [Usage](#Usage) for more information.

![Still from Person of Interest episode "Panopticon", Season 4 Episode 1](docs/panopticon.png)

The inspiration for `fincher` comes from "Panopticon", Season 4 Episode 1 in
Person of Interest, in which _The Machine_ encodes a message as typos in the
dissertation of one of the main characters, Harold Finch.

`fincher` is currently `0.1.0` and considered an **experiment**
and a project for **funsies**. I am very interested in contributions & ideas!

## Disclaimer

While `fincher` is a steganography tool, **no guarantees are made about it's
suitablity for any purpose, especially hiding information from hostile actors**.

Due to the fact that fincher hides messages in a source text as typos, if the
information is stored digitally as text, it would be relatively easy to
run a spellchecking over the text to determine where the typos are, and work
backwards. Possible mitigations are storing text in physical printed form and
encrypting the source message.

## Installation

### via Homebrew (macOS users)

```
$ brew tap maxfierke/fincher
$ brew install fincher
```

### Manually

1. Ensure you have the [crystal compiler installed](https://crystal-lang.org/docs/installation/) (0.25.1+)
2. Clone this repo
3. Run `make install RELEASE=1` to build for release mode and install
4. `fincher` will be installed to `/usr/local/bin` and usable anywhere, provided it's in your `PATH`.

## Usage

```
$ fincher encode

fincher encode [OPTIONS] SOURCE_TEXT_FILE MESSAGE

Arguments:
  MESSAGE           message
  SOURCE_TEXT_FILE  source text file

Options:
  --char-offset NUMBER            character gap between typos (Displacement Strategies: char-offset)
                                  (default: 130)
  --codepoint-shift NUMBER        codepoints to shift (Replacement Strategies: n-shifter)
                                  (default: 7)
  --displacement-strategy STRING  displacement strategy (Options: char-offset, word-offset, matching-char-offset)
                                  (default: matching-char-offset)
  --keymap STRING                 Keymap definition to use for keymap replacement strategy
                                  (default: en-US_qwerty)
  --replacement-strategy STRING   replacement strategy (Options: n-shifter, keymap)
                                  (default: keymap)
  --seed NUMBER                   seed value. randomly generated if omitted
                                  (default: )
  --word-offset NUMBER            word gap between typos (Displacement Strategies: word-offset, matching-char-offset)
                                  (default: 38)
```

### Example

Let's use the part of the introduction paragraph of the [English Wikipedia article for Canada](https://en.wikipedia.org/wiki/Canada)

> Canada is a country in the northern part of North America. Its ten provinces
> and three territories extend from the Atlantic to the Pacific and northward
> into the Arctic Ocean, covering 9.98 million square kilometres (3.85 million
> square miles), making it the world's second-largest country by total area.

This is saved in `test_files/canada.txt`.

Next, we'll encode it with `fincher`.

```
$ fincher encode --displacement-strategy word-offset --word-offset 3 --replacement-strategy n-shifter --codepoint-shift 0 test_files/canada.txt "Hello GitHub"
```

Which will produce this output:

> Canada is a **H**ountry in the **e**orthern part of **l**orth America. Its **l**en provinces and
> **o**hree territories extend **\_**rom the Atlantic **G**o the Pacific **i**nd northward into **t**he
> Arctic Ocean, **H**overing 9.98 **u**illion square kilometres (**b**.85 million square miles
> ), making it the world's second-largest country by total area.


### Displacement strategies

Displacement strategies determine where each character within the message gets
encoded within the source text.

#### `char-offset`

The `char-offset` strategy will distribute each message character by N number of
characters, as specified by the `--char-offset` option.

e.g. `--displacement-strategy char-offset --char-offset 10` will
distribute a character of the message every 10 characters in the source text.

**Relevant options**: `--char-offset`

#### `matching-char-offset`

The `matching-char-offset` strategy will distribute each message character by
finding a matching character at least every N words, as specified by the
`--word-offset` option.

e.g. `--displacement-strategy matching-char-offset --word-offset 10`
will take a message character and ensure there's _at least_ a 10 word gap
since the last message character then find the next matching character in the
source text.

**Relevant options**: `--word-offset`

#### `word-offset`

The `word-offset` strategy will distribute each message character by N number of
words, as specified by the `--word-offset` option.

e.g. `--displacement-strategy char-offset --word-offset 10` will
distribute a character of the message every 10 words in the source text.

**Relevant options**: `--word-offset`

### Replacement strategies

Replacement strategies determine how a character within the source text is
replaced, based on an individual message character.

#### `keymap`

The `keymap` strategy will replace a character within the source text based on
a keymap definition of which keys neighbor it (including Shift modified). The
key chosen will be random.

Which keymap to use can be specified by the `--keymap` option,
e.g. `--keymap en-US_qwerty`, but is of little use right now, as only
`en-US_qwerty` is supported.

`keymap` is best paired with the `matching-char-offset` replacement strategy to
create an effect of a plausible typo.

**Relevant options**: `--keymap`, `--seed`

#### `n-shifter`

The `n-shifter` strategy will replace a character within the source text with
a message character shifted N codepoints, as specified by the `--codepoint-shift`
option.

**Relevant options**: `--codepoint-shift`

## Decoding

You may have noticed that there is no `fincher decode` command. Partly, this is
is because the intention is that the typos are to be resolved by a human reading
the encoded text. However, it is also the case that many of the displacement and
replacement strategy combinations are non-deterministic and potentially lossy.

For example, the `keymap` replacement strategy will (pseudo)randomly decide
which character to use to replace a character in the source text based on the
characters close to a message character on the keyboard.

## Limitations

`fincher` is early stages and has some notable limitations:

* The current displacement and replacement strategies are not context-aware.
  i.e. they do not make judgements based on the content of the source text and
  whether the replacement or displacement makes sense grammatically. This will
  probably change.
* Source text scanning (rightly or wrongly) happens on a rotating
  4K buffer (so you could feed it multi-GB source text, if you wanted to) and
  the `IOScanner` does not handle regex matching across buffer boundaries.
  Therefore, the `--[word|char]-offset` parameters are not applied exactly, but
  will make minimum guarantees about the offset.
* Does not yet take input from `STDIN`, so it cannot be piped to yet. (It does
  however, output to `STDOUT`.)

## Development

To work on `fincher`, you'll need a current version of the Crystal compiler. I
generally try to keep it targeting the latest version, as Crystal is a moving
target, and not all APIs have stability guarantees yet.

I welcome suggestion and discussion of new displacement and replacement
strategies, as well as architectural and interface changes.

## Contributing

1. Fork it ( https://github.com/maxfierke/fincher/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [maxfierke](https://github.com/maxfierke) Max Fierke - creator, maintainer
