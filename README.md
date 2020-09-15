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
 - `sudo service postgres start` starts server, needs to be done on computer restart
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

Parts of the above process can be used to get the other databases in database.yml to work

# How to run the test suite

# Deployment instructions
