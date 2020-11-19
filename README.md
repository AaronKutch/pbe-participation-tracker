# Participation Tracker

A Texas A&M University CSCE 431 project by Scott Wilkins, Aaron Kutch, Cameron Brock, Shawn Tan,
and Sergio Rios

# Getting Started
1. Install ruby 2.7.X
2. Install Node.js and Yarn (LTS or latest stable version recommended)
3. Install PostgreSQL 11.7 or later
4. Clone this repository
5. `cd` into the directory and execute `bundle install`, and `yarn install --check-files`
6. We use environment variables to store the password of the development and test databases. In your respective OS, add the following environment variables (use the same password for both, as the `database.yml` is configured to use the same user to log in to both databases):
```
PBE_PARTICIPATION_TRACKER_DATABASE_PASSWORD="<some password>"
PBE_DEVELOPMENT_DATABASE_PASSWORD ="<some password>"
```
You can see where they're used in `config/database.yml`.

7. Launch PostgreSQL and set up the roles and databases
```
CREATE ROLE pbe_participation_tracker;
ALTER USER pbe_participation_tracker WITH PASSWORD '<password from step 6>';
ALTER ROLE pbe_participation_tracker WITH LOGIN;
ALTER ROLE pbe_participation_tracker WITH CREATEDB;
CREATE DATABASE pbe_participation_tracker_development;
CREATE DATABASE pbe_participation_tracker_test;
GRANT ALL PRIVILEGES ON DATABASE pbe_participation_tracker_development TO pbe_participation_tracker;
GRANT ALL PRIVILEGES ON DATABASE pbe_participation_tracker_test TO pbe_participation_tracker;
```
You may also need to alter the owner of the newly created databases in case the owner is the default Postgres user.
```
ALTER DATABASE pbe_participation_tracker_development OWNER TO pbe_participation_tracker;
ALTER DATABASE pbe_participation_tracker_test OWNER TO pbe_participation_tracker;
```

8. Back in the root directory of the Rails project, run `rails db:migrate`
9. Launch the project with `rails s`

# Running The Test Suite
1. You may need to run `rails db:migrate RAILS_ENV=test ` to set up the test databse
2. Run `rake spec` to execute the tests in the `spec/` directory
3. Run `rubocop` from the root of the project for style checking. NOTE: The first time you migrate, `schema.rb` will fail rubocop tests because it uses double quotes instead of single quotes upon migrating
4. From the root of the project, run `brakeman` for security checks

# Deploying to Heroku

Heroku has a fantastic guide to deploying apps.
Start by following the steps under the [Local setup](https://devcenter.heroku.com/articles/getting-started-with-rails6#local-setup) section.
Then follow the steps under [Deploy your application to Heroku](https://devcenter.heroku.com/articles/getting-started-with-rails6#deploy-your-application-to-heroku).
- Instead of using `git push heroku main`, use `git push heroku master`, as our repository uses the `master` branch by default
- You do not need to manually migrate the database upon deployment. The `Procfile` in the root of the project automatically does this once Heroku successfully builds the app
  - If the migration fails for whatever reason, the app will _not_ be deployed. You can learn more about Heroku's release phase from [their documentation](https://devcenter.heroku.com/articles/release-phase/).
- You may find it useful to create a default admin account after deploying. While in the project directory, run:
```bash
heroku run rails console
# Wait to connect to your dyno
admin = Customer.create(first_name: "first", last_name: "last", email: "email@example.com", password: "password", role: "admin")
admin.save
```

## Transferring Ownership of Heroku App
1. Log in to Heroku and click on the app in your dashboard.
2. Go to the Access tab.
3. Add the new owner as a collaborator, using the same email as their Heroku account.
4. After the new owner accepts the collaborator role, go the the Settings tab.
5. Scroll down to Transfer Ownership, and select a new owner for the app.

For the most detailed and up-to-date information, please visit [Heroku's documentation](https://devcenter.heroku.com/articles/transferring-apps#initiate-transfer).

## Backing Up and Restoring Your Data
The app provides an option to export via CSV, which gives you enough information to manually recreate the state, if need be. Heroku also provides a way to backup the app's database. To proceed, **you will need to install the [Heroku CLI](https://devcenter.heroku.com/articles/heroku-cli)**.

You can create a backup by running `heroku pg:backups:capture --app <your-app-name>`. It will name the backup with a name like `b123`. **NOTE:** This will affect the load on the database, so only perform backups during periods of low activity.

You can download backups by running `heroku pg:backups:url b123 --app <your-app-name>` (replace `b123` with the backup name) and opening the URL. You can also download it via the command line with `heroku pg:backups:download b123`.

Backups can be restored with `heroku pg:backups:restore b123 --app <your-app-name>`. If you would like to restore the latest backup, then you can simply run `heroku pg:backups:restore --app <your-app-name>`.

For the most detailed and up-to-date information on backing up and restoring your data, please refer to [Heroku's documentation](https://devcenter.heroku.com/articles/heroku-postgres-backups).

Restoring your backups from a local copy is more involved, and as such, we recommend following the steps above. However, if you would like to proceed with restoring from a local backup, please refer to [Heroku's documentation](https://devcenter.heroku.com/articles/heroku-postgres-import-export#import).

## Other Notes
### Database
Cheatsheet to get postgres working (assuming you are working on Linux):
 - on Linux installing postgres adds a "postgres" superuser, the password of which may need to be changed to reach the interactive prompt
 - `pg` gem should be installed. The library `libpq-dev` is needed if installing the `pg` gem installation errors with "can't find the libpq-fe.h header" or complains about "pg_config".
 - `sudo service postgresql start` starts server, needs to be done on computer restart
 - `export PBE_DEVELOPMENT_DATABASE_PASSWORD= ...` sets the environment variable used by this database.yml. It's suggested to add this to the Linux bash `.profile` to avoid needing to set this on every restart.
 - `sudo -u postgres psql` starts the interactive prompt, which needs the `postgres` superuser password
 - `CREATE ROLE pbe_participation_tracker;` creates the user/role that this project uses
 - `ALTER USER pbe_participation_tracker WITH PASSWORD '...';` needs to be set the same as $PBE_DEVELOPMENT_DATABASE_PASSWORD
 - `ALTER ROLE "pbe_participation_tracker" WITH LOGIN;` allows login for the user
 - `ALTER ROLE pbe_participation_tracker WITH CREATEDB` because the test suite will create and delete a `pbe_participation_tracker_test` database.
 - the templates may need to be set to use unicode

if `rails db:create db:schema:load` does not work at this point, try narrowing down issues by creating the database manually:
 - `CREATE DATABASE pbe_participation_tracker_development;` creates the developement database
 - `GRANT ALL PRIVILEGES ON DATABASE pbe_participation_tracker_development TO pbe_participation_tracker` so the role can actually use the database

 - `rails db:migrate` is needed for every change to table structure, or the whole database can be dropped and refreshed with `rails db:drop db:create db:schema:load`
 - `sudo service postgresql restart` is needed sometimes

### Test Suite
The default rails test suite has been replaced by rspec under the `spec` folder. Be sure to use the `rake spec` command instead of the `rspec` command which omits certain things.
 - setup the database
 - check that database creation can happen `rails db:drop db:create db:schema:load`
 - use `rails db:seed` or `rails db:reset` if you want to manually test with premade accounts (see `db/seeds.rb`)
 - `rake spec` runs most of the tests
 - check for formatting with the `rubocop` gem
 - `gem install brakeman` and run `brakeman` to check for security issues
