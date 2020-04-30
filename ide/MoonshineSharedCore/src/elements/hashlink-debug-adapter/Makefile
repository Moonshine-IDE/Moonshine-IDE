# requires compiling native extensions with electron support
NPARAMS=--runtime=electron --target=6.1.2 --disturl=https://atom.io/download/electron
LINUX_VM=ncannasse@virtbuntu

all:

deps:
	npm install node-gyp -g
	npm install $(NPARAMS)
	(cd node_modules/deasync && rm -rf bin && node-gyp rebuild $(NPARAMS))	
	
cleanup:
	/bin/find . -name *.obj | xargs rm -f 
	/bin/find . -name *.pdb | xargs rm -f 
	/bin/find . -name *.tlog | xargs rm -rf 
	/bin/find . -name *.map | xargs rm -rf 

# git pull && sudo rm -rf node_modules && sudo make deps on LINUX_VM before running this
import_linux_bindings:
	cp bindings.js node_modules/bindings/	
	make LIB=ffi-napi NAME=ffi_bindings _import_linux_bindings
	make LIB=ref-napi NAME=binding _import_linux_bindings
	make LIB=deasync NAME=deasync _import_linux_bindings

_import_linux_bindings:
	-mkdir node_modules/$(LIB)/build/linux
	pscp $(LINUX_VM):hashlink-debugger/node_modules/$(LIB)/build/Release/$(NAME).node node_modules/$(LIB)/build/linux/
	chmod +x node_modules/$(LIB)/build/linux/$(NAME).node
	-cp bindings.js node_modules/$(LIB)/node_modules/bindings	
	
package: cleanup
	#npm install vsce -g
	vsce package
	
# to get token : 
# - visit https://dev.azure.com/ncannasse/
# - login (@hotmail)
# - click user / security / Personal Access token
publish:
	vsce publish -p `cat vsce_token.txt`