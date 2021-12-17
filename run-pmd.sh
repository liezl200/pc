#!/usr/bin/env bash
all_args="$*"
if [[ ! $all_args == *"-R "* ]]; then
  echo "ERROR: Must specify a PMD ruleset via `-R path_to_ruleset.xml`. Exiting."
  exit 1
fi

idx=1
for (( i=1; i <= "$#"; i++ )); do
    # expect arg list is run-pmd.sh -R ruleset.xml file_a.java file_b.java file_c.java ...
    if [[ ${!i} == *.java ]]; then
        idx=${i}
        break
    fi
done

java_files="${*:idx}"
other_args="${*:1:idx-1}"

pmd pmd -f textcolor -language java $other_args -filelist <(echo "${java_files// /,}")
