Run all of these from within site's context (not from your regular local terminal), i.e. open Local > site > "Open site shell" :

    - init.sh -- this is my custom ".bashrc" script. Not sure how to maintain one single .bashrc throughout all the new Local sites, so I maintain this one. It has some aliases that I use, and xdebug aliases get automatically inserted into this script by the next script. Every time I open a local terminal (via "Open site shell") i also run `$ source init.sh` to load up all my aliases for that terminal session

    - setup_this_site.sh -- this adds config lines for xdebug in my init.sh, and some php.ini things for this local site. Wraps up by outputting instructions what to do next -- run mysql_enable_port.sh and re-source init.sh

    - mysql_enable_port.sh -- this one creates a "root" DB user for this site's local DB, with password "root" and gives it privileges. It outputs port number -- then I use my DB client to create a DB connection -- host: localhost, port: this one, DB name: local, user: root, pass: root

    - import_db.sh -- this is a helper script which automatically does those search&replaces and automates importing any SQL file to my blank new Local site.
