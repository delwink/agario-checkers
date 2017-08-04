OUT=agario-checkers.love
DATA=COPYING COPYING.CC-BY README res/ TRADEMARKS

all: zip

zip:
	zip -ru $(OUT) $(DATA) *.lua
