@echo off
REM Transputer/occam flag simulation -- run single-processor headless simulation
REM
REM Forfeited into the public domain with NO WARRANTY. Read LICENSE for details.

REM Reset transputers by running rspy
rspy

REM Start the flag program running on the transputers
iserver /sb flagsngh.b4h

REM Start the display frontend on the PC. Enjoy!
flagdos
