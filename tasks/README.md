# Tasks

## Admin

### Create an admin account

```
sudo docker-compose -f tasks/admin/docker-compose.yml run discourse-admin-create
```

## Import

### Import from vbulletin4

```
sudo docker-compose up -d postgres redis discourse-sidekiq
sudo docker-compose -f tasks/import/vbulletin4/docker-compose.yml up -d mysql
mysql --host=127.0.0.1 --port=3306 -uroot -p vb4 < dump_file.sql
mkdir -p data/nginx
touch data/nginx/301-redirects-global.map
sudo docker-compose -f tasks/import/vbulletin4/docker-compose.yml run discourse-import-vbulletin4
sudo docker-compose -f tasks/import/vbulletin4/docker-compose.yml down
```

## DB

### (WARNING) Drop and migrate DB

```
sudo docker-compose -f tasks/db/docker-compose.yml run discourse-db-drop
```