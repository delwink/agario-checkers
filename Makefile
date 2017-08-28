OUT=agario-checkers.love
DATA=COPYING COPYING.CC-BY README res/ TRADEMARKS

all: zip

zip:
	rm -f $(OUT)
	zip -r $(OUT) $(DATA) *.lua
