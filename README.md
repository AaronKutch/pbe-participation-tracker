# Participation Tracker

A Texas A&M University CSCE 431 project by Scott Wilkins, Aaron Kutch, Cameron Brock, Shawn Tan,
and Sergio Rios

# Ruby dependencies
  - Ruby 2.7
  - Rails 6.0
  - PostgreSQL 11.7 or later
  - Rubocop 0.x

# Configuration

# Database setup

Cheatsheet to get postgres working (assuming you are working on Linux):
 - on Linux installing postgres adds a "postgres" superuser, the password of which may need to be
   changed to reach the interactive prompt
 - pg gem should be installed. The library `libpq-dev` is needed if installing the `pg` gem
   installation errors with "can't find the libpq-fe.h header" or complains about "pg_config".
 - `sudo service postgresql start` starts server, needs to be done on computer restart
 - `export PBE_DEVELOPMENT_DATABASE_PASSWORD= ...` sets the environment variable used by this
   database.yml, suggested to add this to the Linux bash `.profile` to avoid needing to reset this
   every restart.
 - `sudo -u postgres psql` starts the interactive prompt, which needs the `postgres` superuser password
 - `CREATE ROLE pbe_participation_tracker;` creates the user/role that this project uses
 - `ALTER USER pbe_participation_tracker WITH PASSWORD '...';` needs to be set the same as
   $PBE_DEVELOPMENT_DATABASE_PASSWORD
 - `ALTER ROLE "pbe_participation_tracker" WITH LOGIN;` allows login for the user
 - `ALTER ROLE pbe_participation_tracker WITH CREATEDB` because the test suite will create and
   delete a `pbe_participation_tracker_test` database.
 - the templates may need to be set to use unicode

if `rails db:create db:schema:load` does not work at this point, try narrowing down issues by
creating the database manually:
 - `CREATE DATABASE pbe_participation_tracker_development;` creates the developement database
 - `GRANT ALL PRIVILEGES ON DATABASE pbe_participation_tracker_development TO
    pbe_participation_tracker` so the role can actually use the database

 - `rails db:migrate` is needed for every change to table structure, or the whole database can be
   dropped and refreshed with `rails db:drop db:create db:schema:load`
 - `sudo service postgresql restart` is needed sometimes

# How to run the test suite

The default rails test suite has been replaced by rspec under the `spec` folder. Be sure to use the
`rake spec` command instead of the `rspec` command which omits certain things.

 - setup the database
 - check that database creation can happen `rails db:drop db:create db:schema:load`
 - use `rails db:seed` or `rails db:reset` if you want to manually test with premade accounts (see `db/seeds.rb`)
 - `rake spec` runs most of the tests
 - check for formatting with the `rubocop` gem
 - `gem install brakeman` and run `brakeman` to check for security issues

# Deployment instructions

 - when deploying to Heroku, push to the `master` branch instead of the default `main` branch.
