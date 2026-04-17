---
description: Open XBTI Gallery to browse all community-created BTI personality tests
---

Open the XBTI Gallery in the user's browser:

```bash
open https://xbti.lovstudio.ai
```

After opening, briefly list known BTI variants by checking the cases directory:

```bash
gh api repos/lovstudio/XBTI/contents/cases 2>/dev/null | python3 -c "
import json, sys
try:
    items = json.load(sys.stdin)
    if isinstance(items, list):
        for item in items:
            if item.get('type') == 'dir':
                print(f\"  - {item['name']}\")
    else:
        print('  (no cases yet)')
except:
    print('  (unable to fetch)')
"
```

If no cases directory exists yet, tell the user: "Gallery 还没有案例，用 `/xbti-creator` 创建一个并提交吧！"
