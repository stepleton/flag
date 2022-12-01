LIBRARIAN=ilibr
OCCAM=oc
LINK=ilink
CONFIG=icconf
OCONFIG=occonf
COLLECT=icollect
CC=icc
DELETE=del
LIBOPT=
OCCOPT=
LINKOPT=
CONFOPT=
OCONFOPT=
COLLECTOPT=
COPT=


##### IMAKEF CUT #####

cgatest.b4h: cgatest.c4h 
	$(COLLECT) cgatest.c4h /t  /o cgatest.b4h $(COLLECTOPT)

cgatest.c4h: cgatest.l4h cgatest.t4h 
	$(LINK) /f cgatest.l4h /t4 /h /o cgatest.c4h $(LINKOPT)

cgatest.t4h: cgatest.occ cga.inc cga.t4h 
	$(OCCAM) cgatest /t4 /h /o cgatest.t4h $(OCCOPT)

cga.t4h: cga.occ 
	$(OCCAM) cga /t4 /h /o cga.t4h $(OCCOPT)

clean  : delete
delete :
	-$(DELETE) cgatest.c4h
	-$(DELETE) cgatest.t4h
	-$(DELETE) cga.t4h

