#!/bin/bash

PLANTUML=plantuml
UMLPATH=src
cwd=`dirname "${0}"`

if [ $# -eq 1 ]; then
    if [ "clear" = $1 ]; then
        rm -rf $cwd/dist
    else
        echo "Invalid argument"
    fi
else
    if type "plantuml" > /dev/null 2>&1; then
        mkdir -p $cwd/dist
        ${PLANTUML} `ls $cwd/${UMLPATH}/*.uml`
        mv $cwd/${UMLPATH}/*.png $cwd/dist
    else
        echo "Plantuml not found"
        exit 1
    fi
fi
