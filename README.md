# discourse-docker (and compose)

## Features

* Full dockerized environment
* Start Discourse with 3 commands 
* HTTPS/SSL with letsencrypt out-of-the-box (if you are using a public domain)
* Integrated NGINX redirections for forum migrations

## Starting a test environment in local

Create the docker compose network

```
docker network create discourse_back
```

Start the services

```
sudo docker-compose pull
sudo docker-compose up -d
```

Create an admin account

```
sudo docker-compose -f tasks/admin/docker-compose.yml run discourse-admin-create
```

Open http://discourse.local/latest in a browser

## Defining NGINX rewrite redirects

Uncomment the next line in /docker-compose.yml:
```
- ./data/nginx/301-redirects-global.map:/etc/nginx/snippets/includes/301-redirects-global.map
```

Create a map file with the rewrite content:
```
./data/nginx/301-redirects-global.map >>>

map $request_uri $new_uri {
    default "";
    /source1 /target1;
    /source2 /target2;
    /source3 /target3;
}
```

And start the server:
```
sudo docker-compose pull
sudo docker-compose up -d
```

## Regenerating Lets Encrypt certificates

Just remove the certbot folder and try again
```
rm -rf data/certbot
```

## Acknowledgment

To [Pierre Ozoux](https://lab.libreho.st/libre.sh), because the hard work done by him on Discourse Dockerization project has allowed me to save lot of hours
