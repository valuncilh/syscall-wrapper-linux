#!/usr/bin/env python3
import re
path = "/build/linux-5.10.y/include/linux/types.h"
with open(path, "r") as f:
    content = f.read()
pattern = r"(typedef\s+_Bool\s+bool\s*;)"
match = re.search(pattern, content)
if match:
    orig = match.group(1)
    repl = "#if defined(__STDC_VERSION__) && __STDC_VERSION__ >= 202311L\n/* C23 */\n#else\n" + orig + "\n#endif"
    with open(path, "w") as f:
        f.write(content.replace(orig, repl, 1))
    print("Fixed types.h")
else:
    print("types.h: pattern not found (already fixed?)")
