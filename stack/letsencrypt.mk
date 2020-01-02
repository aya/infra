letsencrypt-certificates:
	docker run --rm -it \
		-v aya_prod_infra_letsencrypt-data:/etc/letsencrypt \
		-v aya_prod_infra_letsencrypt-public:/var/www \
		certbot/certbot \
		certificates

letsencrypt-certonly:
	docker run -it --rm \
		-v aya_prod_infra_letsencrypt-data:/etc/letsencrypt \
		-v aya_prod_infra_letsencrypt-logs:/var/log/letsencrypt \
		-v aya_prod_infra_letsencrypt-public:/var/www \
		certbot/certbot \
		certonly --webroot --webroot-path=/var/www \
		--email hostmaster@autissier.net --agree-tos \
		-d autissier.net \
		-d cloud.autissier.net

letsencrypt-staging-certonly:
	docker run -it --rm \
		-v aya_prod_infra_letsencrypt-data:/etc/letsencrypt \
		-v aya_prod_infra_letsencrypt-public:/var/www \
		certbot/certbot \
		certonly --webroot --webroot=/var/www \
		--register-unsafely-without-email --agree-tos \
		--staging \
		-d autissier.net \
		-d cloud.autissier.net
