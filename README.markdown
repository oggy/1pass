# 1Pass

Unofficial [1Password][1password] reader for the command line.

[1password]: https://agilebits.com/onepassword

## Installation

Install [NPM], then:

    npm install -g 1pass

[npm]: https://npmjs.org/

## Usage

    1pass list [QUERY]

Lists the items in your keychain. If a QUERY is given, only items matching QUERY
are shown. Otherwise all items are listed.

    1pass show QUERY

Lists the full details of all items matching the given QUERY. `show` is the
default command, so unless there's ambiguity, you can shorten this to:

    1pass QUERY

### Queries

`1pass` lets you be brief with your queries. Try just giving a substring, or
omitting characters in the middle of key names. For example `1pass haw` will
match an item named "howaboutwe.com" (as well as anything else containing 'h',
'a', 'w' in that order).

### Your Keychain

By default, `1pass` will look for your data in common locations:

* ~/Library/Application Support/1Password/1Password.agilekeychain
* ~/Dropbox/1Password.agilekeychain

If there's nothing there, it'll ask.

You can point `1pass` to your keychain with a `-d` option.

    1pass -d /path/to/secrets.agilekeychain list

`1pass` does not remember your selection, nor is there a configuration file
yet. For now, please use a shell alias.

## Help

As always:

    1pass --help

## Disclaimer

1Pass is not developed, maintained, or endorsed by Agile Bits, creator of
1Password. Use at your own risk.

## Contributing

 * [Bug reports](https://github.com/oggy/1pass/issues)
 * [Source](https://github.com/oggy/1pass)
 * Patches: Fork on Github, send pull request.
   * Include tests where practical.
   * Leave the version alone, or bump it in a separate commit.

## Copyright

Copyright (c) George Ogata. See LICENSE for details.
