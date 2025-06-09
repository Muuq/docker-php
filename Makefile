build-php83:
	docker build -t qumuinc/php:v8.3 .
push-php83:
	docker tag qumuinc/php:v8.3 qumuinc/php:v8.3
	docker push qumuinc/php:v8.3
