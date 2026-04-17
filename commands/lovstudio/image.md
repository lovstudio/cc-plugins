---
aliases: "/image"
---

Run the local image generation skill directly.

Steps:
1. Parse the arguments as the image prompt. If the user specifies a filename (e.g. "save as foo.png"), use it; otherwise generate a filename like `image_$(date +%s).png`.
2. Execute the script:
   ```bash
   python3 "/Users/mark/.claude/plugins/marketplaces/anthropic-agent-skills/image-gen/gen_image.py" "PROMPT_HERE" -o "FILENAME_HERE"
   ```
   *Note: This will automatically open the image on macOS. Use `-q high` for better quality, or `--ascii` to see a terminal preview.*
3. Inform the user of the file location: "Image saved to: [FILENAME]"