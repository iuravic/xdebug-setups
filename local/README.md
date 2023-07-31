Run all of these from within site's context (not from your regular local terminal), i.e. open Local > site > "Open site shell" :

- `init.sh` -- a custom ".bashrc" script. Not sure how to maintain one single .bashrc throughout all the Local sites, so I maintain this one. It has some aliases that I regularly use, and xdebug specific aliases get automatically inserted into this script by the next script `setup_this_site.sh`. Every time a site's Local terminal is opened (via "Open site shell") `$ source init.sh` also gets executed in my terminal which loads up all the aliases for that terminal session

- `setup_this_site.sh` -- this configures newly added local site
  - adds xdebug config
  - aliases to init.sh
  - some php.ini config
  - wraps up by outputting instructions about what to do next -- run `mysql_enable_port.sh` and re-source `init.sh`

- `mysql_enable_port.sh` -- this creates a "root" DB user for this site's local DB and gives it necessary schema privileges. It outputs port number so that a DB client of choice can be used to create a DB connection -- `host: localhost, port: this one, DB name: local, user: root, pass: root`

- `import_db.sh` -- this is a helper script which automatically imports any SQL file to my blank new Local site
