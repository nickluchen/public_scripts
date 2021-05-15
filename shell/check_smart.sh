#!/bin/bash

check_and_report()
{
  disk=$1
  report=/tmp/smart_report.txt

  /usr/sbin/smartctl -a ${disk} > ${report}

  #grep "PASSED" ${report} > /dev/null

  # Prepare the email contents
  #email_body=/tmp/smart_chk_email.txt
  #echo "SMART check fails with ${disk}." > ${email_body}
  #echo "Full reports are:" > ${email_body}
  #cat ${report} > ${email_body}
  email_body=${report}

  # Send the email to clu
  cat ${email_body} | mail -s "SMART Checking report" clu
}

##### START HERE #####
## Check the input argument
if [ -n "$1" ]; then
  DISKS=$1
fi

for disk in ${DISKS[*]}; do
  check_and_report ${disk}
done
