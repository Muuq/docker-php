build-php83:
	docker build -t qumuinc/php:v8.3 .
push-php83:
	docker tag qumuinc/php:v8.3 qumuinc/php:v8.3
	docker push qumuinc/php:v8.3
build-amd64arm64:
	docker buildx build --platform linux/amd64,linux/arm64 -t qumuinc/php:v8.3 --push .