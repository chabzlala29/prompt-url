# Prompt URL

Executable program to download raw html files from the web

## Install

### Clone the repository

```shell
git clone git@github.com:chabzlala29/prompt-url.git
cd prompt-url
```

### Check your Ruby version

```shell
ruby -v
```

The ouput should start with something like `ruby 2.7.1`

If not, install the right ruby version using [rbenv](https://github.com/rbenv/rbenv) (it could take a while):

```shell
rbenv install 2.7.1
```

### Install dependencies

```shell
bundle install
```

## Run tests

```shell
bundle exec rspec spec
```

## Using the command

```shell
./app/bin/fetch-url https://google.com
```

It will output the HTML file to output folder.
