Automating the backup of BaseX DB

Setup:
--
* Create the directories: 
  * `mkdir /var/basex/backup/bin`
  * `mkdir /var/basex/backup/backup.daily`
  * `mkdir /var/basex/backup/bin/backup.monthly`
  * `mkdir /var/basex/backup/bin/backup.weekly`
* populate "bin" with the contents of the GitHub repo - `https://github.com/cwrc/islandora_cwrc_basexdb/tree/master/scripts/backup/bin`
* `cp /var/basex/backup/bin/basex_backup.cron /etc/cron.d/basex_backup.cron`
  * sudo ln -s /var/basex/backup/bin/basex_backup.cron /etc/cron.d/basex_backup.cron yeilds a "wrong file owner" error as the /etc/cron.d/ files need to be owned by root




backup_basex.sh
-
* script handling the backup

userkey
-
file containing the username/password to execute the backup
* do not add to the GitHub repo
* username password on one line

backup_basex_rotate.sh
-
* script to rotate the backup files out of the data directory

basex_backup.cron
-
* cron job to run the backup and rotate
* setup
 * sudo ln -s /var/basex/backup/bin/basex_backup.cron /etc/cron.d/basex_backup.cron


restore
-
* copy from: /var/basex/backup/backup.daily/ to /var/basex/BaseXData
* execute 'restore db_name' from basexclient
