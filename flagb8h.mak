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

flagb8h.btl: flagb8h.cfb 
	$(COLLECT) flagb8h.cfb /o flagb8h.btl $(COLLECTOPT)

flagb8h.cfb: flagb8h.pgm flagboss.c4h flaglast.c4h flagwrkr.c4h 
	$(OCONFIG) flagb8h.pgm /o flagb8h.cfb $(OCONFOPT)

flagboss.c4h: flagboss.l4h flagboss.t4h 
	$(LINK) /f flagboss.l4h /t4 /h /o flagboss.c4h $(LINKOPT)

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

flaglast.c4h: flaglast.l4h flaglast.t4h 
	$(LINK) /f flaglast.l4h /t4 /h /o flaglast.c4h $(LINKOPT)

flaglast.t4h: flaglast.occ flagwrkr.t4h 
	$(OCCAM) flaglast /t4 /h /o flaglast.t4h $(OCCOPT)

flagwrkr.t4h: flagwrkr.occ
	$(OCCAM) flagwrkr /t4 /h /o flagwrkr.t4h $(OCCOPT)

flagwrkr.c4h: flagwrkr.l4h flagwrkr.t4h 
	$(LINK) /f flagwrkr.l4h /t4 /h /o flagwrkr.c4h $(LINKOPT)

clean  : delete
delete :
	-$(DELETE) flagb8h.clu
	-$(DELETE) flagb8h.cfb
	-$(DELETE) flagboss.c4h
	-$(DELETE) flagboss.t4h
	-$(DELETE) cga.t4h
	-$(DELETE) flagconf.t4h
	-$(DELETE) flagdraw.t4h
	-$(DELETE) flagflag.t4h
	-$(DELETE) flaglast.c4h
	-$(DELETE) flaglast.t4h
	-$(DELETE) flagwrkr.t4h
	-$(DELETE) flagwrkr.c4h

