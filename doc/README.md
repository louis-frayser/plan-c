* The Plan
NOTE:  Most if these items are in _DONE_ status.  The markup just isn't rendered properly at GitHub.  The few items remaining will be moved to bug tracking system on GitHub.

** Current design, repair and enhancement strategies
*** DONE Save form data to disk after aggregating changes.
1. Saving is done, but decided to save before aggregation, so
   more detail is preserved. This was done be accident, but
   the result seems better than the original [no pun ] plan.
 
*** DONE If saved data exists in a recent file, use it rather than the original
    file on disk. -- #'retrieve-plan-c
*** DONE Save new daily data to separate file directories on disk
    If the current date is newer than that of the saved data,
    stash the disk data to history; start with fresh values
    for today. -- #'retrieve-plan-c

** FIXME
*** Critical
**** DONE Entering a {duration} of 12:00 (instead of 0:12) for and activity, Cello practice, caused the system to crash, processing the plots.

**** DONE Activities are definitely disappearing from the WWW display
     1. After entry, some previous entries disappear. Mon 10:04:39
     2. In the database, it seems the missing value (time-duration)
        was assigned to  the wrong activity
**** DONE Crashes if ':' is missing from input time-string.
     1. Also fails on '::' - to many colons.
     2. (note: add validation 1st to the server, then to the client)
         validation need to occur before storage.

**** DONE Crash on input of hours
- Adding 1 hr of time to an existing crashes the response.
  #f instead of number was the error.


*** Bad
**** TODO Often the  1st visit reports Timeout
**** DONE Redirect/get is not correct--sends the page to nowhere.
I want to redirect back the start page.
**** DONE Items entered from another client don't show

*** Annoying
**** TODO Filter out inputs > 16 hrs in the validation.
     Just entered 30:00 instead of 0:30.
     ==========
     Mon Apr 03 05:23:55 PDT 2023
     17:00 is still accepted.
**** DONE Date a top of form is static; need to be updated on refresh (or clock charge)
**** TODO Needs ability to edit past events (especially the prior day)
**** DONE Often it seems that WWW-form input is not excepted and needs to be repeated.
     Fixed by adding a confirmation dialog.  No posts can happen without consent.

*** Cosmetic
**** DONE Make form-label text bold.
**** DONE Fix clock background color.

*** Wish List
**** STARTED Make the amount of detail displayed adjustable
     It was not anticipated, but by saving data as activities rather than as  plans, more
     detail is available (the date and time and any repetitions of an activity are
       now available.
      1. It would be nice to provide a version of the display with like
         activities aggregated. As the display with the new detail is now
	 different but still interesting.
      2. An ability to show all detail including times activities were performed
         is  also desired.
	 #2 above is DONE.
**** DONE Add time of day to page 
**** DONE Add total time to page
**** TODO Add a Notes field to Activity
**** DONE Expand the multiple-instrument fields in music practice
**** Add Historical 'Edit/Add/Delete' to plan


