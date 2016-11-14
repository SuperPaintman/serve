# Serve

[![Linux Build][travis-image]][travis-url]
[![Shards version][shards-image]][shards-url]


Command line static HTTP server


![Screenshot][screenshot-image]


## Installation

Download from **github**:

```sh
$ serve_version="0.1.0"
$ serve_arch="x86_64"
$ curl -Lo /usr/local/bin/serve.gz "https://github.com/SuperPaintman/serve/releases/download/v${serve_version}/serve-${serve_version}_linux_${serve_arch}.gz"
$ gunzip /usr/local/bin/serve.gz
$ chmod +x /usr/local/bin/serve
```


From sources:

```sh
$ cd ~/Projects
$ git clone https://github.com/SuperPaintman/serve
$ cd ./serve
$ make
$ sudo make install
$ # or
$ sudo make reinstall
```


--------------------------------------------------------------------------------

## Usage

```sh
$ serve -h
```


--------------------------------------------------------------------------------

## Test

```sh
$ crystal spec
# or
$ make test
```


--------------------------------------------------------------------------------

## Shell tab auto-completion

To enable tab auto-completion for **Serve**, add one of the following lines
to your `~/.zshrc` file.

```sh
# Zsh, ~/.zshrc
if [[ -z $commands[serve] ]]; then
    echo 'serve is not installed, you should install it first'
else
    eval "$(serve --completion=zsh)"
fi
```


--------------------------------------------------------------------------------

## Contributing

1. Fork it (<https://github.com/SuperPaintman/serve/fork>)
2. Create your feature branch (`git checkout -b feature/<feature_name>`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin feature/<feature_name>`)
5. Create a new Pull Request


--------------------------------------------------------------------------------

## Contributors

- [SuperPaintman](https://github.com/SuperPaintman) SuperPaintman - creator, maintainer


--------------------------------------------------------------------------------

## API
[Docs][docs-url]


--------------------------------------------------------------------------------

## Changelog
[Changelog][changelog-url]


--------------------------------------------------------------------------------

## License

[MIT][license-url]


[license-url]: LICENSE
[changelog-url]: CHANGELOG.md
[docs-url]: https://superpaintman.github.io/serve/
[screenshot-image]: README/screenshot.png
[travis-image]: https://img.shields.io/travis/SuperPaintman/serve/master.svg?label=linux
[travis-url]: https://travis-ci.org/SuperPaintman/serve
[shards-image]: https://img.shields.io/github/tag/superpaintman/serve.svg?label=shards
[shards-url]: https://github.com/superpaintman/serve

