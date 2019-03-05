GITCOMMIT := $(shell git rev-parse --short=7 HEAD 2>/dev/null)
NAME=dev

all: build

build:
	docker build -t vdenoise/${NAME}:${GITCOMMIT} .

push:
	@echo "==> Publishing vdenoise/${NAME}:$(GITCOMMIT)"
	@docker tag vdenoise/${NAME}:$(GITCOMMIT) vdenoise/${NAME}:latest
	@docker push vdenoise/${NAME}:$(GITCOMMIT)
	@docker push vdenoise/${NAME}:latest
	@echo "==> Your image is now available at vdenoise/${NAME}:$(GITCOMMIT)"

run: kill
	docker run -it -h dev -d --net=host --rm -v /var/run/docker.sock:/var/run/docker.sock -v /home/vincent:/home/vincent -v /home/vincent/.ssh:/home/vincent/.ssh -v /home/vincent/.zsh_private:/home/vincent/.zsh_private -v /home/vincent/.zsh_history:/home/vincent/.zsh_history --cap-add=SYS_PTRACE --security-opt seccomp=unconfined --privileged --name dev vdenoise/dev 

ssh:
	mosh --no-init --ssh="ssh -o StrictHostKeyChecking=no -i ~/.ssh/id_rsa -p 3222" vincent@localhost -- tmux new-session -AD -s main

kill:
	docker kill dev | true


.PHONY: all build run kill
