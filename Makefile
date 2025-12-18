image:
	docker build --pull -t influxdb-container .

run:
	docker run --rm -d -p 8086:8086 --name influxdb influxdb-container

stop:
	docker stop influxdb || true

clean: stop
	docker image rm -f influxdb-container || true

logs:
	docker logs -f influxdb

shell:
	docker exec -it influxdb /bin/sh

.PHONY: image run stop clean logs shell