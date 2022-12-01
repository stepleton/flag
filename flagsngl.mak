LIBRARIAN=ilibr
OCCAM=oc
LINK=ilink
CONFIG=icconf
OCONFIG=occonf
COLLECT=icollect
CC=icc
DELETE=del
LIBOPT=
OCCOPT=/a /k /g /u /n
LINKOPT=
CONFOPT=
OCONFOPT=
COLLECTOPT=
COPT=


##### IMAKEF CUT #####

flagsngl.b4h: flagsngl.c4h 
	$(COLLECT) flagsngl.c4h /t  /o flagsngl.b4h $(COLLECTOPT)

flagsngl.c4h: flagsngl.l4h flagsngl.t4h 
	$(LINK) /f flagsngl.l4h /t4 /h /o flagsngl.c4h $(LINKOPT)

flagsngl.t4h: flagsngl.occ flagboss.t4h flagwrkr.t4h intsize.inc 
	$(OCCAM) flagsngl /t4 /h /o flagsngl.t4h $(OCCOPT)

flagboss.t4h: flagboss.occ cga.inc flagconf.inc flagflag.inc cga.t4h \
              flagconf.t4h flagdraw.t4h flagflag.t4h intsize.inc 
	$(OCCAM) flagboss /t4 /h /o flagboss.t4h $(OCCOPT)

cga.t4h: cga.occ 
	$(OCCAM) cga /t4 /h /o cga.t4h $(OCCOPT)

flagconf.t4h: flagconf.occ flagconf.inc 
	$(OCCAM) flagconf /t4 /h /o flagconf.t4h $(OCCOPT)

flagdraw.t4h: flagdraw.occ cga.inc 
	$(OCCAM) flagdraw /t4 /h /o flagdraw.t4h $(OCCOPT)

flagflag.t4h: flagflag.occ flagflag.inc cga.t4h 
	$(OCCAM) flagflag /t4 /h /o flagflag.t4h $(OCCOPT)

flagwrkr.t4h: flagwrkr.occ
	$(OCCAM) flagwrkr /t4 /h /o flagwrkr.t4h $(OCCOPT)

clean  : delete
delete :
	-$(DELETE) flagsngl.c4h
	-$(DELETE) flagsngl.t4h
	-$(DELETE) flagboss.t4h
	-$(DELETE) cga.t4h
	-$(DELETE) flagconf.t4h
	-$(DELETE) flagdraw.t4h
	-$(DELETE) flagflag.t4h
	-$(DELETE) flagwrkr.t4h

