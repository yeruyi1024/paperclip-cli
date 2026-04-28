paperclip-hermes:
	docker build --no-cache -f ./env-default/Dockerfile -t paperclip-hermes ../paperclip/

paperclip-hermes-nexa:
	docker build --no-cache -f ./env-hermes/Dockerfile -t paperclip-hermes-nexa ../paperclip/