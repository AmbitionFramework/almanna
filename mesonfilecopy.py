#!/usr/bin/env python
import sys
import shutil

shutil.copyfile(sys.argv[1], sys.argv[2])
shutil.copymode(sys.argv[1], sys.argv[2])