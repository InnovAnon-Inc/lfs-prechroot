.PHONY: all prechroot push clean commit
.SECONDARY: sources/.sentinel

all:    prechroot
push:   prechroot
	docker push     innovanon/lfs-$<
prechroot: sources/.sentinel
	docker build -t innovanon/lfs-$@ $(TEST) .
commit:
	git add .
	git commit -m '[Makefile] commit' || :
	git pull
	git push

sources/.sentinel: $(shell find sources -type f)
	touch $@

clean:
	rm -vf */.sentinel .sentinel

