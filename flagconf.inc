-- Transputer/occam flag simulation -- constants for configuring flag workers
-- vim: ft=occam
--
-- Forfeited into the public domain with NO WARRANTY. Read LICENSE for details.


-- Error conditions for FlagConfig
VAL kFlagConfigSuccess IS 0 :   -- Nothing is wrong.
VAL kFlagConfigTimeout IS 1 :   -- Timed out trying to negotiate with workers.
VAL kFlagConfigTooBig IS 2 :    -- The flag would overload one of the workers.
VAL kFlagConfigMismatch IS 3 :  -- Workers replied with an unexpected value.
