In process of migrating code to open-source. Everything except the parser has been released.

# Installing

PostgreSQL, Redis and 7z are required.

    $ mkdir -p files/replays
    $ mkdir -p files/packs

    $ bundle install

## Mac OS X

    $ brew install postgresql
    $ brew install redis
    $ brew install p7zip

## Linux

    $ apt-get install p7zip-full

## Running

Make sure Postgres and Redis are running and accessible from localhost.

    $ foreman start
    $ rails s
  
# TODO

 - Forgery protection!!!
 - ext3 ~30k sub-directory per inode limit (careful with packs)