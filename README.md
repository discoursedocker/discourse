# discourse-docker (and compose)

## Features

* Full dockerized environment
* Start Discourse with 3 commands 
* HTTPS/SSL with letsencrypt out-of-the-box (if you are using a public domain)
* Integrated NGINX redirections for forum migrations
* Most common tasks are also dockerized for comfort

## Starting a test environment in local

Create the docker compose network

```
sudo docker network create discourse_back
```

Start the services

```
sudo docker-compose pull
sudo docker-compose up -d
```

Wait some minutes until db migrations and static files precompilation finish

Create an admin account

```
sudo docker-compose -f tasks/admin/docker-compose.yml run discourse-admin-create
```

Point discourse.local to 127.0.0.1 in your /etc/hosts file

Open https://discourse.local/latest in a browser

Note: HTTPS is used even in local with self-signed certificates

## Defining NGINX rewrite redirects

If you need some manual redirections you can define a map file for nginx

Uncomment the next line in /docker-compose.yml:
```
- ./data/nginx/301-redirects-global.map:/etc/nginx/snippets/includes/301-redirects-global.map
```

Create the map file (./data/nginx/301-redirects-global.map) with the rewrite content:
```
map $request_uri $new_uri {
    /source1 /target1;
    /source2 /target2;
    /source3 /target3;
}
```

And start the server:
```
sudo docker-compose up -d
```

Note: For forum migrations, the import script must generate a map file with the redirections

## Troubleshooting

### Regenerating Lets Encrypt certificates

Just remove the certbot folder and start the services again
```
rm -rf data/certbot
```

## Acknowledgment

To [Pierre Ozoux](https://lab.libreho.st/libre.sh), because the hard work done by him on Discourse Dockerization project has allowed me to save lot of hours
