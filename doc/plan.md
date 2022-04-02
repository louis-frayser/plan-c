# The Plan

## Current strategy

1. Save formdata to disk after agregating changes.
2. If saved data exists in a recent file, use it rather than the original
   file on disk.
3. If the current date is newer the the saved data,
   stash the disk data to history; start with fresh values
   for today.
   
## FIXME
1. Adding time to and existing item doesn't update, but replaces the 
original. Logic is there to add; it must be broken. There is some 
old logic still there; the now code is only called in display mode.
