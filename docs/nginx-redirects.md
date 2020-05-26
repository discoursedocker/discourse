# Defining NGINX rewrite redirects

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