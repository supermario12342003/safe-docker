#Installation For Local Development
1. configure .env by copy .env-example
```$xslt
cp .env-example .env
```
2. launch the servers and database
```
docker-compose up
```
3. When the servers are up, in another terminal
```$xslt
docker exec --user dev -it container_name bash
#composer install
```  
4. if encounter forbidden access to resouce error
```$xslt
docker exec -it container_name bash
#chown -R dev:www-data ./wordpress
```