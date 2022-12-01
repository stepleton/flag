@echo off
REM Transputer/occam flag simulation -- build all versions of the simulation
REM
REM Tested with a make program from Borland Turbo C++.
REM
REM Forfeited into the public domain with NO WARRANTY. Read LICENSE for details.
@echo on

make -fflagb8h
make -fflagb8
make -fflagsngh
make -fflagsngl
