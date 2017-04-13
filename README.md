# Image
Based on go image, this image download, compile, and install every libs needed by GTK3, and GTK3 itself.

# Usage
Here is a `Dockerfile` based on this image

```Dockerfile
FROM krostar/go-gtk:1.8-3.18

RUN mkdir -p /go/src/github.com/user/myproject
WORKDIR /go/src/github.com/user/myproject
```

and how I use it with a Makefile

```Makefile
BINARY_NAME			:= myproject

# GTK version to use, see https://github.com/gotk3/gotk3/wiki
GTK_VERSION			?= $(shell pkg-config --modversion gtk+-3.0 | sed -E 's/([0-9]+)\.([0-9]+).*/gtk_\1_\2/')
GTK_TAG				:= -tags $(GTK_VERSION)

BUILD_FLAGS			:= $(GTK_TAG)

$(BINARY_NAME):
	mkdir -p $(DIR_BUILD)/bin
	go build -i -v -o bin/$(BINARY_NAME) $(BUILD_FLAGS)

run: $(BINARY_NAME)
	$bin/$(BINARY_NAME)

docker-build:
	# build the docker image from the Dockerfile
	docker build -t image:tag .
	# stop the instance before running it, in case we start it before
	docker stop image_tag_instance 2>&1 > /dev/null || true
	# run the image
		# DISPLAY=$(DISPLAY) => allow the gtk3 window to be displayed on your monitor
		# --net=host => useful if you need to call others services started on your host
		# -v $(shell pwd):/go/src/github.com/user/myproject => mount the code on the instance to allow go to find your code
		# tail -f /dev/null => since we don't want the image to stay alive after the build, keep it running with this infinite command
	docker run --name image_tag_instance -d --rm -e DISPLAY=$(DISPLAY) --net=host -v $(shell pwd):/go/src/github.com/user/myproject image:tag tail -f /dev/null
	xhost +localhost

docker-run:
	# run the project in the docker instance
	docker exec image_tag_instance make run

docker-exec:
	# run a command on the instance (ex: $> make docker-exec CMD=bash)
	docker exec -it image_tag_instance $(CMD)

.PHONY: $(BINARY_NAME) run docker-build docker-run docker-exec
```

# Example project who use this image
[github.com/krostar/nebulo-client-desktop](github.com/krostar/nebulo-client-desktop)
