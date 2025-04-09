#!/bin/bash
# Merge all PDFs in the current directory into 'merged.pdf'
/System/Library/Automator/Combine\ PDF\ Pages.action/Contents/MacOS/join --output merged.pdf *.pdf
