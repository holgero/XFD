all:
	$(MAKE) -C device
	$(MAKE) -C host
	( cd java; mvn clean install )
