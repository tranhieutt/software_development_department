import textwrap
import math

def create_hexagon(x, y, size, label, color="#c99b20", text_color="#1d1916"):
    points = []
    for i in range(6):
        angle_deg = 60 * i + 30
        angle_rad = math.pi / 180 * angle_deg
        px = x + size * math.cos(angle_rad)
        py = y + size * math.sin(angle_rad)
        points.append(f"{px},{py}")
    
    poly_points = " ".join(points)
    return f"""
    <g>
        <polygon points="{poly_points}" fill="{color}" stroke="#1d1916" stroke-width="2" />
        <text x="{x}" y="{y+5}" font-family="Inter, sans-serif" font-size="14" font-weight="600" fill="{text_color}" text-anchor="middle">{label}</text>
    </g>
    """

def create_cylinder(x, y, w, h, label, color="#7d6350"):
    ry = 10
    return f"""
    <g>
        <path d="M {x} {y+ry} L {x} {y+h-ry} A {w/2} {ry} 0 0 0 {x+w} {y+h-ry} L {x+w} {y+ry} A {w/2} {ry} 0 0 0 {x} {y+ry} Z" fill="{color}" stroke="#1d1916" stroke-width="2" />
        <ellipse cx="{x+w/2}" cy="{y+ry}" rx="{w/2}" ry="{ry}" fill="{color}" stroke="#1d1916" stroke-width="2" />
        <text x="{x+w/2}" y="{y+h/2+5}" font-family="Inter, sans-serif" font-size="14" font-weight="600" fill="#f8f6f3" text-anchor="middle">{label}</text>
    </g>
    """

def create_arrow(x1, y1, x2, y2, color="#1d1916", dashed=False):
    dash_attr = 'stroke-dasharray="5,5"' if dashed else ""
    return f"""
    <line x1="{x1}" y1="{y1}" x2="{x2}" y2="{y2}" stroke="{color}" stroke-width="2" marker-end="url(#arrowhead)" {dash_attr} />
    """

svg_content = f"""
<svg width="1000" height="800" viewBox="0 0 1000 800" xmlns="http://www.w3.org/2000/svg">
    <defs>
        <marker id="arrowhead" markerWidth="10" markerHeight="7" refX="10" refY="3.5" orient="auto">
            <polyline points="0 0, 10 3.5, 0 7" fill="none" stroke="#1d1916" stroke-width="1.5" />
        </marker>
        <style>
            @import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;600&amp;display=swap');
        </style>
    </defs>
    
    <rect width="1000" height="800" fill="#f8f6f3" />
    
    <text x="500" y="50" font-family="Inter, sans-serif" font-size="32" font-weight="600" fill="#1d1916" text-anchor="middle">SDD PROJECT ARCHITECTURE: STEEL DISCIPLINE</text>
    <text x="500" y="80" font-family="Inter, sans-serif" font-size="16" fill="#7d6350" text-anchor="middle">Style 6: Claude Official Premium Branding</text>

    <text x="150" y="150" font-family="Inter, sans-serif" font-size="18" font-weight="600" fill="#7d6350">TIER 1: STRATEGIC</text>
    {create_hexagon(300, 200, 50, "@cto")}
    {create_hexagon(500, 200, 50, "@tech-director")}
    {create_hexagon(700, 200, 50, "@producer")}

    <text x="150" y="350" font-family="Inter, sans-serif" font-size="18" font-weight="600" fill="#7d6350">TIER 2: TACTICAL</text>
    {create_hexagon(200, 400, 50, "@product-mgr")}
    {create_hexagon(400, 400, 50, "@lead-prog")}
    {create_hexagon(600, 400, 50, "@qa-lead")}
    {create_hexagon(800, 400, 50, "@release-mgr")}

    <text x="150" y="550" font-family="Inter, sans-serif" font-size="18" font-weight="600" fill="#7d6350">TIER 3: OPERATIONAL</text>
    {create_hexagon(200, 600, 50, "@frontend")}
    {create_hexagon(400, 600, 50, "@backend")}
    {create_hexagon(600, 600, 50, "@ui-spec")}
    {create_hexagon(800, 600, 50, "@specialists")}

    {create_cylinder(425, 700, 150, 60, "SUPERMEMORY")}

    {create_arrow(300, 250, 400, 350)}
    {create_arrow(700, 250, 800, 350)}
    {create_arrow(200, 450, 200, 550)}
    {create_arrow(400, 450, 400, 550)}
    {create_arrow(600, 450, 600, 550)}
    
    {create_arrow(500, 700, 400, 650, color="#7d6350", dashed=True)}
    
    <text x="500" y="780" font-family="Inter, sans-serif" font-size="12" fill="#1d1916" text-anchor="middle">2026 SDD System Integration | High Fidelity Architecture</text>
</svg>
"""

import os
with open("e:/SDD-Upgrade/docs/sdd-architecture.svg", "w", encoding="utf-8") as f:
    f.write(svg_content)
