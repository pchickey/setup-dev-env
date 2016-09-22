#!/usr/bin/env python

import sys
import os
import hashlib

ALIGN = 256

for f in sys.argv[1:]:
    if os.path.isfile(f):
        data = open(f,'r').read()

        sha256 = hashlib.sha256()
        sha256.update(data)

        over_boundary = len(data) % ALIGN

        if 0 < over_boundary:
            required = ALIGN - over_boundary
            sha256.update('\xFF' * required)
        digest = sha256.hexdigest()
        print("%s\t%s" % (digest[0:16], f))
