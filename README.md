docker-compose -f docker-compose.local.yaml build --no-cache
docker-compose -f docker-compose.local.yaml up -d --build


docker build --target=production -t myapp:prod .
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d