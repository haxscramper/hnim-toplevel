debian-base:
	docker build -t debian-base -f debian-base-dockerfile .

nim-base: debian-base
	docker build -t nim-base -f nim-base-dockerfile .

nim-more: nim-base
	docker build -t nim-more -f nim-more-dockerfile .

nim-standalone:
	cat debian-base-dockerfile nim-base-dockerfile > nim-standalone-dockerfile
	sed -i '/^FROM nim-base/d; /^#/d' nim-standalone-dockerfile
	docker build -t nim-stanalone -f nim-standalone-dockerfile .

public-docker-images: nim-more nim-base debian-base
	docker build -t haxscramper/debian-base -f nim-base-dockerfile .
	docker build -t haxscramper/nim-base -f nim-base-dockerfile .
	docker build -t haxscramper/nim-more -f nim-more-dockerfile .
