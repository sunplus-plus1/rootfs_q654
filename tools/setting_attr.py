#!/usr/bin/env python3

import os
import sys

RED = "\033[31m"
RESET = "\033[0m"

def setting_attr(root, attr_file):
    with open(attr_file, "r") as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            result=line.split(":", 3)
            mode=result[0]
            uid=result[1]
            gid=result[2]
            path=result[3]
            os.chown(root + path[1:], int(uid), int(gid))
            os.chmod(root + path[1:], int(mode, 8))

if __name__=="__main__":
    if len(sys.argv) < 3:
        sys.exit(1)
    try:
        setting_attr(sys.argv[1], sys.argv[2])
        print("setting attr ok.")
    except Exception as e:
        print(RED + "", e, RESET, file=sys.stderr)
        sys.exit(1)
