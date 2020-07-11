# safe-docker

##Usage
```

```

##Tips
```
mysqldump -u USERNAME --password=PASS DATABASE_NAME -h DATABASEHOST > NAME-dump.sql
cat ./NAME-dump.sql | docker exec -i safe_database_1 /usr/bin/mysql -u mengwei --password=1234 DATABASE_NAME
```