#!/usr/bin/env python3
"""Медиа-вьювер ТГ открывается на том же мониторе, где главное окно ТГ.
Статичным windowrule не выразить: монитор ТГ меняется (special:music ходит за фокусом)."""
import json, os, socket, subprocess

TG = "org.telegram.desktop"
VIEWER = "Media viewer"


def clients():
    return json.loads(subprocess.run(["hyprctl", "-j", "clients"],
                                     capture_output=True, text=True).stdout)


def follow(addr):
    wins = clients()
    viewer = next((w for w in wins if w["address"] == addr), None)
    main = next((w for w in wins if w["class"] == TG and w["title"] != VIEWER), None)
    if not viewer or not main or viewer["monitor"] == main["monitor"]:
        return
    mons = json.loads(subprocess.run(["hyprctl", "-j", "monitors"],
                                     capture_output=True, text=True).stdout)
    target = next(m for m in mons if m["id"] == main["monitor"])
    subprocess.run(["hyprctl", "dispatch", "movetoworkspace",
                    f'{target["activeWorkspace"]["id"]},address:{addr}'])


s = socket.socket(socket.AF_UNIX)
s.connect(f"/run/user/{os.getuid()}/hypr/{os.environ['HYPRLAND_INSTANCE_SIGNATURE']}/.socket2.sock")
buf = b""
while True:
    chunk = s.recv(4096)
    if not chunk:
        break
    buf += chunk
    while b"\n" in buf:
        line, buf = buf.split(b"\n", 1)
        ev = line.decode(errors="replace")
        # openwindow>>ADDR,WS,CLASS,TITLE
        if ev.startswith("openwindow>>") and ev.endswith(f",{TG},{VIEWER}"):
            follow("0x" + ev.split(">>", 1)[1].split(",", 1)[0])
