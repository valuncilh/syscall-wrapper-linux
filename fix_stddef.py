#!/usr/bin/env python3
path = "/build/linux-5.10.y/include/linux/stddef.h"
with open(path, "r") as f:
    content = f.read()
old = "enum {\n\tfalse\t= 0,\n\ttrue\t= 1\n};"
new = "#if defined(__STDC_VERSION__) && __STDC_VERSION__ >= 202311L\n/* C23 */\n#else\nenum {\n\tfalse\t= 0,\n\ttrue\t= 1\n};\n#endif"
if old in content:
    with open(path, "w") as f:
        f.write(content.replace(old, new, 1))
    print("Fixed stddef.h")
else:
    print("stddef.h: pattern not found (already fixed?)")
