#!/usr/bin/env python3

import json
import os
import subprocess
import sys


def main() -> int:
    if len(sys.argv) != 2:
        print("Usage: notify.py <NOTIFICATION_JSON>")
        return 1

    try:
        notification = json.loads(sys.argv[1])
    except json.JSONDecodeError:
        return 1

    match notification_type := notification.get("type"):
        case "agent-turn-complete":
            cwd = os.getcwd()
            root_folder = os.path.basename(cwd) or "~"
            title = f"Codex -> {root_folder}"
            message = "Agent turn Complete."

        case _:
            print(f"not sending a push notification for: {notification_type}")
            return 0

    subprocess.check_output(
        [
            "terminal-notifier",
            "-title",
            title,
            "-message",
            message,
            "-group",
            "codex",
            "-activate",
            "com.mitchellh.ghostty",
        ]
    )

    return 0


if __name__ == "__main__":
    sys.exit(main())
