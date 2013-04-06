#!/bin/bash

# I'm not sure if craigslist is monitoring for robots crawling their site, but I through a sleep between 0 and 60 seconds in case they were looking for access exactly on some minute interval
NUMBER=$[ ( $RANDOM % 60 )  + 1 ]
sleep $NUMBER

# Curl a craigslist search result into a temp file.  Note that you have to clear the user-agent or cariglsist will detect that you are coming from curl and give you mangled output.
curl -c -nc -q -t 0 --user-agent "" "http://boston.craigslist.org/search/aap?bedrooms=1&srchType=A&format=rss" 2>/dev/null > /tmp/apt 

# Now take the xml and run it through a sed program that will translate it into sql
# 1. egrep for lines that start with <title> or <item (but that are not the top level <title>craigslist ....
# 2. run through sed program
cat /tmp/apt | egrep "(^<title>|<item rdf:about=)" | egrep -v "(^<title>craigslist)" | sed '
#  first escape any quotes
s/"/\"/g; 

#  each listing is two lines an <item> followed by a <title>

# <item>
# the <item> will be converted into the first part of the sql statement "insert ignore"
s/<item rdf:about=\(.*\)>/insert ignore into apts (url, title, price, bd) values(\1,/g; 

#  the title xml can be constructed in a few different ways.  There seems to always be a dollar value, and usually theres a number of bedrooms:
s/^<title><!\[CDATA\[\(.*\) \$\([0-9]*\) \([0-9]\)bd\]\]><\/title>$/"\1","\2","\3");/g; 

#  sometimes theres a bunch of extra crap after the bedroom count, this picks up those cases:
s/^<title><!\[CDATA\[\(.*\) \$\([0-9]*\) \([0-9]\)bd.*\]\]><\/title>$/"\1","\2","\3");/g;  

#  this is kind of a catch all, in case neither of the two above statements catches it, just dump everything in the title
s/^<title><!\[CDATA\[\(.*\)\]\]><\/title>$/"\1","0","0");/g;
' | mysql -uroot apartments
