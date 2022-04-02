# The Plan

## Current strategy

1. Save formdata to disk after agregating changes.
2. If saved data exists in a recent file, use it rather than the original
   file on disk.
3. If the current date is newer the the saved data,
   stash the disk data to history; start with fresh values
   for today.
   
## FIXME
1. Adding 1hr of time to an existing crashes the response.
2. The display is is changing to add newest items on top; put them
   at the bottom, so the screen does appear to jump.
3. Error #f instead of number, now particular line of code given
   plan-c.rkt
