#!/usr/bin/env bash

frozen_requirement_files="Array"

# Adds frozen file changes to frozen_requirement_files check in like "Array @ scholastic @ bastion .."
for file in $(git diff --cached --name-only)
do 
	if [[ $file =~ ^deploy\/configs\/[a-z\/]*requirements-frozen.txt? ]]; then
		core_file=${file#"deploy/configs/"}
		core_file=${core_file%"/requirements-frozen.txt"}
		frozen_requirement_files="${frozen_requirement_files} @ ${core_file}"
	fi
done

# Checks if requirements.txt changes are reflected in the changes. 
for file in $(git diff --cached --name-only)
do 
	# the /deploy code's pip file is scio_requirements, so adding an edge case for that. 

	if [[ $file == "deploy/docker/bazel/scio_requirements.txt" || $file == "python_scio/scio_requirements.txt" ]]; then
		if [[ ! frozen_requirement_files == "*deploy*" ]]; then
			sh tools/update-requirements-frozen.sh deploy
		fi
		continue
	fi

	# requirements_lite.txt handles bastion. Therefore making sure if the requirements_lite is touched, we update bastion.
	if [[ $file == "python_scio/requirements_lite.txt" ]]; then
		if [[ ! frozen_requirement_files == "*bastion*" ]]; then
			sh tools/update-requirements-frozen.sh bastion
		fi
		continue
	fi

	if [[ $file =~ ^deploy\/configs\/[a-z\/]*requirements.txt? && ! $file =~ ^deploy\/configs\/[a-z\/]*frozen-requirements.txt? ]]; then
		core_file=${file#"deploy/configs/"}
		core_file=${core_file%"/requirements.txt"}
		if [[ ! $frozen_requirement_files == *$core_file* ]]; then
			sh tools/update-requirements-frozen.sh $core_file
		fi
	fi

done