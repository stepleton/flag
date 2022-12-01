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

flagsngh.b4h: flagsngh.c4h 
	$(COLLECT) flagsngh.c4h /t  /o flagsngh.b4h $(COLLECTOPT)

flagsngh.c4h: flagsngh.l4h flagsngh.t4h 
	$(LINK) /f flagsngh.l4h /t4 /h /o flagsngh.c4h $(LINKOPT)

flagsngh.t4h: flagsngh.occ flagboss.t4h flagwrkr.t4h intsize.inc 
	$(OCCAM) flagsngh /t4 /h /o flagsngh.t4h $(OCCOPT)

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
	-$(DELETE) flagsngh.c4h
	-$(DELETE) flagsngh.t4h
	-$(DELETE) flagboss.t4h
	-$(DELETE) cga.t4h
	-$(DELETE) flagconf.t4h
	-$(DELETE) flagdraw.t4h
	-$(DELETE) flagflag.t4h
	-$(DELETE) flagwrkr.t4h

