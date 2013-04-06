#!/bin/bash

# Query some sql and store the output in a variable
OUTPUT=`echo "
-- Report fields
select 
 if(url not like '%fee%','*','') as fee
 , bd as bedrooms

-- calculation of the price per bedroom, amortizing fee over the first year
 , round(price/bd*if(url like '%fee%',13/12,1)) price_per_bdrm
 , title
 , time_created
 , url 
from apts

-- My Search Criteria:
-- apartments referring to all of Cambridge, or to Kendall or Inman neighborhoods
where title like '%cambridge%' or title like 'kendall' or title like '%inman%' 

-- apartments referring to Central (as in central square, not central air conditioning)
or (title like '%central%' and title not like '%central air%' and title not like '%central A\/C%')

-- look only for stuff in the last hour
and time_created>date_sub(now(), interval 61 minute) 

-- look for cheap places (less than 1000 per room)
having price_per_bdrm<1000 

-- look at cheapest places first
order by price_per_bdrm asc;" | mysql -uroot apartments`

# Check how much output there is and only send an email if there is more than one line of output
output_linecount=`echo "$OUTPUT" | wc -l`
if [ $output_linecount -gt 1 ]
then
   d=`date +"%m-%d %H:%M"`
   echo "$OUTPUT" | mutt -s"${d} new cambridge housing listings" cgaguilar@gmail.com,geoff.fudenberg@gmail.com
fi
