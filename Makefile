paperclip-hermes:
	docker build --no-cache -f ./env-default/Dockerfile -t paperclip-hermes ../paperclip/

paperclip-hermes-nexa:
	docker build --no-cache -f ./env-nexa/Dockerfile -t paperclip-hermes-nexa ../paperclip/

paperclip-hermes-nexa-latest:
	docker build --no-cache -f ./env-nexa/Dockerfile -t paperclip-hermes-nexa:P05180-H0516 ../paperclip/