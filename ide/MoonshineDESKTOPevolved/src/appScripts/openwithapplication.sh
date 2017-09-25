#!/bin/bash

# load the parameters.  use "" for the third parameter if there are no arguments.
APP=$1


# open the URL with the application
xattr -d -r com.apple.quarantine "$1"
