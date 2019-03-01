FROM braedon/prometheus-es-exporter:0.5.1 AS dist

COPY exporter.cfg /usr/src/app

FROM dist as local
