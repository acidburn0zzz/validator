FILES=*.js *.css *.html *.cgi lib  .htaccess
JSFILES=source/*.js
CSSFILES=source/*.css

BETA=/var/www/beta.validator.test-ipv6.com/
PROD=/var/www/validator.test-ipv6.com/

default:: beta

beta:
	make DESTDIR=$(BETA) install
	
prod:
	make DESTDIR=$(PROD) install



install: index.js index.css
	mkdir -p $(DESTDIR)/cache
	ls -ld $(DESTDIR)/cache | cut -f1 | grep drwsrwxrwx || sudo chmod 4777 $(DESTDIR)/cache
	rsync -av $(FILES) $(DESTDIR)/



index.js: $(JSFILES)
	cat $(JSFILES) > index.js
	 
index.css: $(CSSFILES)
	cat $(CSSFILES) > index.css
	