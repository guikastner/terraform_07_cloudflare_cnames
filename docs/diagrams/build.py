#!/usr/bin/env python3
"""Gera os diagramas Excalidraw (.excalidraw) e imprime as URLs Kroki para o README.

Uso: python3 docs/diagrams/build.py
"""
import base64
import json
import pathlib
import zlib

HERE = pathlib.Path(__file__).parent
_seed = 1


def _base(kind, x, y, w, h, **kw):
    global _seed
    _seed += 1
    el = {
        "id": f"{kind}-{_seed}", "type": kind, "x": x, "y": y, "width": w, "height": h,
        "angle": 0, "strokeColor": "#1e1e1e", "backgroundColor": "transparent",
        "fillStyle": "hachure", "strokeWidth": 2, "strokeStyle": "solid", "roughness": 1,
        "opacity": 100, "groupIds": [], "frameId": None, "roundness": {"type": 3},
        "seed": _seed, "version": 1, "versionNonce": _seed, "isDeleted": False,
        "boundElements": None, "updated": 1, "link": None, "locked": False,
    }
    el.update(kw)
    return el


def text(x, y, s, size=20, color="#1e1e1e", w=None):
    lines = s.split("\n")
    w = w or max(len(l) for l in lines) * size * 0.55
    h = len(lines) * size * 1.25
    return _base("text", x, y, w, h, text=s, originalText=s, fontSize=size, fontFamily=1,
                 textAlign="center", verticalAlign="middle", baseline=int(size * 0.9),
                 containerId=None, lineHeight=1.25, strokeColor=color, roundness=None)


def box(x, y, w, h, label, bg, size=20, shape="rectangle"):
    r = _base(shape, x, y, w, h, backgroundColor=bg)
    t = text(x, y, label, size, w=w)
    t["y"] = y + (h - t["height"]) / 2
    return [r, t]


def arrow(x1, y1, x2, y2, label=None, dashed=False):
    a = _base("arrow", x1, y1, x2 - x1, y2 - y1, points=[[0, 0], [x2 - x1, y2 - y1]],
              startArrowhead=None, endArrowhead="arrow", roundness={"type": 2},
              strokeStyle="dashed" if dashed else "solid", lastCommittedPoint=None,
              startBinding=None, endBinding=None)
    out = [a]
    if label:
        t = text(0, 0, label, 16, color="#495057")
        t["x"] = (x1 + x2) / 2 - t["width"] / 2
        t["y"] = (y1 + y2) / 2 - t["height"] - 6
        out.append(t)
    return out


def scene(elements):
    return {"type": "excalidraw", "version": 2, "source": "build.py",
            "elements": elements, "appState": {"viewBackgroundColor": "#ffffff", "gridSize": None},
            "files": {}}


def fluxo():
    e = []
    e += box(20, 140, 200, 110, "dns.json\n(o segredo\nda casa)", "#ffec99")
    e += box(320, 140, 200, 110, "tofu apply\n(a mágica)", "#a5d8ff")
    e += box(620, 40, 240, 100, "CNAMEs\nblog → github.io", "#b2f2bb")
    e += box(620, 250, 240, 120, "A 192.0.2.1\n(proxied, IP\nde mentirinha)", "#ffc9c9")
    e += box(960, 250, 240, 120, "Redirect Rule\napp → destino", "#d0bfff")
    e += arrow(220, 195, 320, 195, "lê")
    e += arrow(520, 170, 620, 95, "cria")
    e += arrow(520, 220, 620, 300, "cria")
    e += arrow(860, 310, 960, 310, "+ regra")
    e.append(text(380, 420, "Cloudflare: “ok, chefe” ☁️", 24, color="#f08c00"))
    return scene(e)


def visitante():
    e = []
    e += box(20, 120, 180, 100, "🧑 Visitante\napp.kastner.com.br", "#ffec99", size=18)
    e += box(300, 100, 260, 140, "Cloudflare Edge\n“esse host tem\nRedirect Rule!”", "#a5d8ff", size=18)
    e += box(660, 120, 240, 100, "301 → destino\n.example.com", "#b2f2bb", size=18)
    e += box(300, 330, 260, 90, "192.0.2.1\n(nunca é chamado 😴)", "#e9ecef", size=18)
    e += arrow(200, 170, 300, 170, "GET /x")
    e += arrow(560, 170, 660, 170, "Location")
    e += arrow(430, 240, 430, 330, "nope", dashed=True)
    return scene(e)


def kroki_url(kind, source):
    data = base64.urlsafe_b64encode(zlib.compress(source.encode(), 9)).decode()
    return f"https://kroki.io/{kind}/svg/{data}"


if __name__ == "__main__":
    for name, fn in {"fluxo": fluxo, "visitante": visitante}.items():
        src = json.dumps(fn(), ensure_ascii=False, indent=1)
        (HERE / f"{name}.excalidraw").write_text(src + "\n")
        print(f"{name}: {kroki_url('excalidraw', src)}")
    for mmd in sorted(HERE.glob("*.mmd")):
        print(f"{mmd.stem}: {kroki_url('mermaid', mmd.read_text())}")
