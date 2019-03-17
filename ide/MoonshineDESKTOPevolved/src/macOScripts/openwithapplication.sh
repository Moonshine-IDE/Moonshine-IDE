#!/bin/bash

# load the parameters.  use "" for the third parameter if there are no arguments.
APP=$1
ARGS=$2


# open the URL with the application
open -a "$1" --args $2