# Installing

PostgreSQL, Redis and 7z are required.

    $ mkdir -p files/replays
    $ mkdir -p files/packs
    
    $ git submodule init
    $ git submodule update
    
    $ python setup.py develop

    $ bundle install
    $ rake db:create
    $ rake db:migrate

## Mac OS X

    $ brew install postgresql
    $ brew install redis
    $ brew install p7zip

## Linux
Install PostgreSQL and Redis
    
    $ apt-get install p7zip-full

## Running

Make sure Postgres and Redis are running and accessible from localhost.

    $ foreman start
    $ rails s

# TODO

 - Forgery protection!!!
 - ext3 ~30k sub-directory per inode limit (careful with packs)