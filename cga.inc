-- Transputer/occam flag simulation -- CGA graphical display constants+inlines
-- vim: ft=occam
--
-- Forfeited into the public domain with NO WARRANTY. Read LICENSE for details.
--
-- Routines that plot coloured dots onto a CGA video frame, inlined for speed.
-- If you don't want inlining, consider wrapping these routines in PROCs in
-- your own library.


-- {{{***** Includes *****
-- CGA colour half-nibble table
-- To set the colour of pixel j of the four pixels in a byte to colour i, add
-- kCgaPalette[(4*i)+j] to the byte. The last row is a mask used for clearing
-- out any old value at pixel j.
VAL []INT kCgaPalette IS [#00, #00, #00, #00,
                          #40, #10, #04, #01,
                          #80, #20, #08, #02,
                          #C0, #30, #0C, #03,
                          #3F, #CF, #F3, #FC] :

-- How many bytes do we use for a CGA video buffer?
VAL kCgaBufferBytes IS 200 * 80 :
-- }}}


-- {{{CgaClear -- Clear (zero out) the display buffer.
--
-- Args:
--   frame: An 80x200 byte array holding a CGA video frame; interleaved or not,
--       it doesn't matter, it's going to be completely zeroed out
INLINE PROC CgaClear ([]BYTE frame)
  -- This is the INMOS way to clear a buffer! See initBYTEvec in tech.note 17:
  -- https://www.transputer.net/tn/17/tn17.html#x1-150002.2
  -- It takes advantage of MOVE, the transputer's memory block copying opcode
  INT block :
  SEQ
    -- Step one: clear out at least half the buffer in doublingly-large steps
    -- by repeatedly copying the N bytes you've zeroed so far to the next N
    -- bytes in the buffer
    INT next.block :
    SEQ
      frame[0] := 0  -- N starts out small: just this first byte!
      block := 1
      next.block := 2
      WHILE next.block <= kCgaBufferBytes
        SEQ
          VAL block.size IS block :  -- Just for legibility
          [frame FROM block FOR block.size] := [frame FROM 0 FOR block.size]
          block := next.block
          next.block := next.block + next.block
    -- Step two: You've got less than half the buffer to go, so finish up by
    -- filling the remaining bytes from the part of the buffer already zeroed
    VAL block.size IS kCgaBufferBytes - block :
    [frame FROM block FOR block.size] := [frame FROM 0 FOR block.size]
:
-- }}}


-- {{{CgaDraw -- Draw a pixel to an interleaved CGA mode 4/5 display buffer
--
-- Draws a picture to an "interleaved" display buffer, meaning that even rows
-- of the picture are stored in a contiguous block and odd rows are stored
-- in a second contiguous block. BEWARE: arguments are not checked --- make
-- certain they are in bounds!
--
-- Args:
--   x, y: Coordinates of the pixel to draw; x must be in 0..319; y in 0..199
--   colour: The colour to paint the pixel with; must be in 0..3
--   cga.palette: kCgaPalette, defined above
--   frame: An 80x200-byte array whose first 8000 bytes holds the even rows
--       of the frame and whose second 8000 bytes holds the odd rows of same
INLINE PROC CgaDraw (VAL INT x, y, colour, VAL []INT cga.palette, []BYTE frame)
  VAL odd.offset IS 8000 :  -- 80 * 100
  VAL x.mod.4 IS x /\ 3 :
  VAL quarter.x IS x >> 2 :  -- Woe betide you if x is negative...
  VAL half.y IS y >> 1 :     -- ...or Y for that matter.
  VAL nibble IS cga.palette[(colour << 2) + x.mod.4] :
  VAL mask IS cga.palette[16 + x.mod.4] :
  IF
    (y /\ 1) <> 0  -- Is this an odd row?
      VAL i IS odd.offset + ((80 TIMES half.y) + quarter.x) :
      frame[i] := BYTE (((INT frame[i]) /\ mask) \/ nibble)
    TRUE  -- This must be an even row.
      VAL i IS (80 TIMES half.y) + quarter.x :
      frame[i] := BYTE (((INT frame[i]) /\ mask) \/ nibble)
:
-- }}}


-- {{{FlatDraw -- Draw a pixel to a flat CGA mode 4/5 display buffer
--
-- Draws a picture to a "flat" display buffer, meaning no interleaving: all
-- rows are stored contiguously in order. BEWARE: arguments are not checked
-- --- make certain they are in bounds!
--
-- Args:
--   x, y: Coordinates of the pixel to draw; x must be in 0..319; y in 0..199
--   colour: The colour to paint the pixel with; must be in 0..3
--   cga.palette: kCgaPalette, defined above
--   frame: An 80x200-byte array forming a "flat" video buffer
INLINE PROC FlatDraw (VAL INT x, y, colour, VAL []INT cga.palette, []BYTE frame)
  VAL x.mod.4 IS x /\ 3 :
  VAL quarter.x IS x >> 2 :  -- Woe betide you if x is negative...
  VAL nibble IS cga.palette[(colour << 2) + x.mod.4] :
  VAL mask IS cga.palette[16 + x.mod.4] :
  VAL i IS (80 TIMES y) + quarter.x :
  frame[i] := BYTE (((INT frame[i]) /\ mask) \/ nibble)
:
-- }}}
