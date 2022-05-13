#! /bin/sh
files=$(git status |sed -n -e 's/.*modified: \+//p' | xargs grep -l ' $')
if [ -n "$files" ]
then echo "Fixing $files..."
     sed -i -e 's/ \+$//' $files && echo "ok."
else echo  "No irregular files" 1>&2 
fi
