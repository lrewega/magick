all::

CONVERT = convert
MONTAGE = montage
CURL = curl -f
RM = rm -f

# ICON_SIZE * 2
RAW_SIZE = 256x256

# RAW_SIZE / sqrt(2)
RAW_DIAG = 181x181

# RAW_SIZE / 2
ICON_SIZE = 128x128

c/fire.png: url=https://emojipedia-us.s3.dualstack.us-west-1.amazonaws.com/thumbs/240/apple/129/fire_1f525.png
c/data.jpg: url=https://images.huffingtonpost.com/2012-04-19-Data2copy.jpg
c/droplet.png: url=https://emojipedia-us.s3.dualstack.us-west-1.amazonaws.com/thumbs/240/apple/129/droplet_1f4a7.png

all:: data-feelin-the-heat.png

data-feelin-the-heat.png: c/fire.png c/data.jpg c/droplet.png
	$(CONVERT) c/fire.png \
		\( c/data.jpg \
			-fuzz 25% -fill none -draw "alpha 0,0 floodfill" -draw "alpha 381,0 floodfill" \
			-channel alpha -blur 0x1 -level 50x100% +channel \
			-gravity south -chop 0x118 \
			-resize 160x160 -repage +0+20 \) \
		\( c/droplet.png \
			-resize 48x48 -repage +90+46 \) \
			-background none -flatten +repage \
		$@

c/hst-sm4.jpeg: url=https://upload.wikimedia.org/wikipedia/commons/3/3f/HST-SM4.jpeg

all:: hst.png

hst.png: c/hst-sm4.jpeg
	$(CONVERT) $< \
		-alpha set -bordercolor black -border 1 -fill none -fuzz 8% -draw "color 0,0 floodfill" \
		-shave 1x1 -trim \
		$@

all:: hst-favicon.ico

hst-favicon.ico: hst.png
	$(CONVERT) $< \
		-background none -gravity center -resize $(ICON_SIZE) -extent $(ICON_SIZE) \
		-define icon:auto-resize=64,48,32,16 \
		$@

all:: hst-spinner.gif

hst-spinner.gif: hst.png

c/hotdog.png: url=https://emojipedia-us.s3.dualstack.us-west-1.amazonaws.com/thumbs/240/apple/155/hot-dog_1f32d.png

all:: spindog.gif

spindog.gif: c/hotdog.png

c/xerus.gif: url=https://i.giphy.com/media/3oKIPlxY9K490RtCw0/giphy-downsized.gif

all:: xerus.gif

xerus.gif: c/xerus.gif | Makefile
	$(CONVERT) -dispose previous $< \
		-alpha set -bordercolor white -border 1 -fill none -fuzz 32% -draw "color 0,0 floodfill" \
		-shave 1x1 -trim -background none -gravity center -resize $(ICON_SIZE) -extent $(ICON_SIZE) \
		-coalesce -layers optimize +map -loop 0 \
		$@

all:: hst-fire.gif

hst-fire.gif: hst-spinner.gif c/fire.png c/droplet.png Makefile
	$(CONVERT) \
		-alpha set -background none -gravity center \
		c/fire.png -scale $(ICON_SIZE) -extent $(ICON_SIZE) -trim \
		\( hst-spinner.gif -scale $(ICON_SIZE) -extent $(ICON_SIZE) -coalesce -trim -set dispose previous \) \
		-coalesce null: \
		\( c/droplet.png -scale 48x48 -repage +24-16 \) \
		-layers composite \
		-delete 0 \
		-loop 0 \
		+dither \
		-scale 96x96 \
		-layers optimize +map \
		$@


c/toronto-skyline.png: url=https://purepng.com/public/uploads/large/purepng.com-city-skylinecitycitiesskylineskyscrapers-251520164457vrrnd.png

all:: toronto-skyline.png

toronto-skyline.png: c/toronto-skyline.png
	$(CONVERT) $< \
		-background none -trim -gravity east -adaptive-resize $(ICON_SIZE)^ +repage -extent 128x128 \
		$@

all:: left-brace.png right-brace.png semicolon.png ack.png err.png

left-brace.png: label={
right-brace.png: label=}
semicolon.png: label=;
ack.png: label=ACK
err.png: label=err
looped-square.png: label=⌘
looped-square.png: font=Arial

# Download and cache inputs using the url variable.
c/%:
	@mkdir -p c/
	$(CURL) -o $@ $(url)
	touch $@

# Create montages on demand, for debugging.
%-montage.gif: %.gif
	$(MONTAGE) $< \
		-tile x1 -geometry '+2+2' -background none -bordercolor none \
		$@

# Magically make spinning gifs from any image.
%.gif:
	$(CONVERT) \
		\( -alpha set -background none \
			-delay 5 \
			-gravity center \
			-dispose previous \
			$< -resize $(RAW_DIAG) \
			-extent $(RAW_SIZE) +repage \
			-duplicate 24 -distort ScaleRotateTranslate %[fx:t*360/n] \
			-trim -layers TrimBounds \
			-layers optimize +map \
			-loop 0 \) \
		-coalesce -resize $(ICON_SIZE) \
		$@

font = CatamaranBk
# Turn text into an image with a phony label target and the text variable
%.png: Makefile
	@test -n '$(label)' # Label must be non-empty
	$(CONVERT) \
		-background none -gravity center \
		-fill black -font $(font) -pointsize 200 label:'$(label)' \
		-trim -resize $(ICON_SIZE) -extent $(ICON_SIZE) \
		$@

clean-cache:
	$(RM) -r c/

clean:
	$(RM) *.png *.ico *.gif *-montage.gif

distclean: clean clean-cache

.PHONY: all clean clean-cache distclean
