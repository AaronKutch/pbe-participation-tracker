# Participation Tracker

A Texas A&M University CSCE 431 project by Scott Wilkins, Aaron Kutch, Cameron Brock, Shawn Tan,
and Sergio Rios

# Ruby dependencies

# Configuration

# Database setup

Cheatsheet to get postgres working (assuming you are working on Linux):
 - on Linux installing postgres adds a "postgres" superuser, the password of which may need to be
   changed to reach the interactive prompt
 - pg gem should be installed
 - `sudo service postgresql start` starts server, needs to be done on computer restart
 - `export PBE_DEVELOPMENT_DATABASE_PASSWORD= ...` sets the environment variable used by this
   database.yml, suggested to add this to the Linux bash `.profile` to avoid needing to reset this
   every restart.

 - `sudo -u postgres psql` starts the interactive prompt, which needs the `postgres` superuser password
 - `CREATE ROLE pbe_participation_tracker;` creates the user/role that this project uses
 - `ALTER USER pbe_participation_tracker WITH PASSWORD '...';` needs to be set the same as
   $PBE_DEVELOPMENT_DATABASE_PASSWORD
 - `ALTER ROLE "pbe_participation_tracker" WITH LOGIN;` allows login for the user
 - `CREATE DATABASE pbe_participation_tracker_development;` creates the developement database
 - `GRANT ALL PRIVILEGES ON DATABASE pbe_participation_tracker_development TO
    pbe_participation_tracker` so the role can actually use the database

 - `rails db:migrate` is needed for every change to table structure
 - `sudo service postgresql restart` is needed sometimes
 - the templates may need to be set to use unicode

Parts of the above process can be used to get the other databases in database.yml to work

# How to run the test suite

The default rails test suite has been replaced by rspec under the `spec` folder. Be sure to use the
`rake spec` command instead of the `rspec` command which omits certain things.

 - `rails db:create` (may have to manually drop the two databases to refresh)
 - `rails db:migrate RAILS_ENV=test` is sometimes needed
 - `ALTER ROLE pbe_participation_tracker WITH CREATEDB` because the test suite will create and
   delete a `pbe_participation_tracker_test` database.

# Deployment instructions
