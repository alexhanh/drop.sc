# Installing

PostgreSQL, Redis and 7z are required.

## Mac OS X

    $ brew install postgresql
    $ brew install redis
    $ brew install p7zip

## Linux
Install PostgreSQL, Redis and 7z (p7zip-full)
    
    $ apt-get install p7zip-full

## Other stuff
    $ mkdir -p files/replays
    $ mkdir -p files/packs
    
    $ git submodule init
    $ git submodule update
    
    $ python setup.py develop

    $ bundle install
    $ rake db:create
    $ rake db:migrate

# Running

Make sure Postgres and Redis are running and accessible from localhost.

    $ foreman start
    $ rails s