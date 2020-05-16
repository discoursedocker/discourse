sleep 10
bundle exec ruby script/import_scripts/vbulletin.rb

REWRITES_FILE=script/import_scripts/301-redirects-global.map

# formatting to nginx map file with right urls
sed -r "s/XXX(.+)\s\sYYY(.+)$/~$NGINX_REWRITE_SOURCE_TOPIC_REGEX \/t\/redirect\/\2;/g" script/import_scripts/vb_map.csv > $REWRITES_FILE.tmp

# adding map definition block
sed -i '1imap $request_uri $new_uri {' $REWRITES_FILE.tmp
echo '}' >> $REWRITES_FILE.tmp

# setting map_hash_max_size to fit the entire file
MAPLINES=$(wc -l < "$REWRITES_FILE")
sed -i "1imap_hash_max_size $MAPLINES;" $REWRITES_FILE.tmp

cp $REWRITES_FILE.tmp $REWRITES_FILE