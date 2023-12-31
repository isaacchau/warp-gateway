all:	clean
	 docker build -t warp-gateway .

run: 
	docker compose up -d
	#docker run -d --rm --privileged --cap-add NET_ADMIN --name warp -v ./data:/var/lib/cloudflare-warp --ip 172.17.0.2 warp-gateway
clean:
	docker-compose down --remove-orphans -v
	docker image  prune -f
	docker volume prune -f
