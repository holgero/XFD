all:
	$(MAKE) -C device VID=$(VID) PID=$(PID)
	$(MAKE) -C host VID=$(VID) PID=$(PID)
	( cd java; \
	  mkdir -p usbleds/src/main/resources; \
	  echo "vendor.id=$(VID)" > usbleds/src/main/resources/address.properties; \
	  echo "product.id=$(PID)" >> usbleds/src/main/resources/address.properties; \
	  mvn clean install )
