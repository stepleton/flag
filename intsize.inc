-- How big is an integer? In Occam, you find out in a silly way.
-- vim: ft=occam
--
-- Forfeited into the public domain with NO WARRANTY. Read LICENSE for details.
--
-- The silly way was said to be recommended by an INMOS engineer:
-- https://groups.google.com/g/comp.sys.transputer/c/cJ7QkVaTLrc/m/eT7nNNUWq8EJ


-- {{{Move along, nothing to see here...
VAL silly.silly.int.silly IS 0 :
VAL []BYTE silly.silly.bytes.silly RETYPES silly.silly.int.silly :
-- }}}


-- kSizeofInt will be the size of an integer (in bytes) on this transputer.
VAL kSizeofInt IS SIZE silly.silly.bytes.silly :
