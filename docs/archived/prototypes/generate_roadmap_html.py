import re

def markdown_to_html():
    with open(r"e:\SDD-Upgrade\scratch\agentic-ai-engineer-roadmap-vi.md", "r", encoding="utf-8") as f:
        content = f.read()

    # Define HTML components
    html_start = """<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Lộ Trình Kỹ Sư Agentic AI 2026 | Anthropic Style</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        :root {
            --bg-color: #fcfaf8;
            --text-color: #312721;
            --accent-color: #d97757;
            --border-color: #e8e1da;
            --card-bg: #ffffff;
            --header-bg: rgba(252, 250, 248, 0.95);
            --secondary-text: #6b5d54;
            --code-bg: #1a1614;
            --nav-link: #8d7e75;
            --shadow: 0 4px 30px rgba(0, 0, 0, 0.05);
        }

        * { margin: 0; padding: 0; box-sizing: border-box; }
        html { scroll-behavior: smooth; }
        body {
            font-family: 'Inter', -apple-system, sans-serif;
            background-color: var(--bg-color);
            color: var(--text-color);
            line-height: 1.7;
            -webkit-font-smoothing: antialiased;
        }

        header {
            position: sticky; top: 0; z-index: 1000;
            background-color: var(--header-bg);
            backdrop-filter: blur(8px);
            border-bottom: 1px solid var(--border-color);
            padding: 1rem 2rem;
            display: flex; justify-content: space-between; align-items: center;
        }

        .logo { font-weight: 700; font-size: 1rem; color: var(--text-color); display: flex; align-items: center; gap: 0.75rem; text-transform: uppercase; letter-spacing: 0.05em; }
        .logo-icon { width: 16px; height: 16px; background: var(--text-color); border-radius: 2px; }

        main { max-width: 900px; margin: 0 auto; padding: 4rem 2rem; }

        .hero { margin-bottom: 6rem; text-align: center; }
        .badge { display: inline-block; background: #e6e2df; color: var(--text-color); padding: 0.4rem 1rem; border-radius: 4px; font-size: 11px; font-weight: 700; margin-bottom: 1.5rem; text-transform: uppercase; letter-spacing: 0.1em; }
        h1 { font-size: 3.5rem; font-weight: 800; line-height: 1.1; margin-bottom: 1.5rem; letter-spacing: -0.04em; }
        .hero p { font-size: 1.25rem; color: var(--secondary-text); max-width: 700px; margin: 0 auto; font-weight: 300; }

        .grid-toc { display: grid; grid-template-columns: repeat(auto-fill, minmax(280px, 1fr)); gap: 1rem; margin-bottom: 8rem; }
        .toc-card {
            background: var(--card-bg); border: 1px solid var(--border-color); padding: 1.5rem; border-radius: 12px;
            text-decoration: none; color: inherit; transition: all 0.3s cubic-bezier(0.16, 1, 0.3, 1);
        }
        .toc-card:hover { border-color: var(--accent-color); transform: translateY(-4px); box-shadow: var(--shadow); }
        .toc-card h3 { font-size: 1.1rem; margin-bottom: 0.25rem; display: flex; align-items: center; gap: 0.5rem; color: var(--text-color); }
        .toc-card h3 span { color: var(--accent-color); font-weight: 600; opacity: 0.6; }
        .toc-card p { font-size: 0.85rem; color: var(--secondary-text); }

        section { margin-bottom: 8rem; scroll-margin-top: 100px; }
        .section-header { margin-bottom: 3rem; border-bottom: 1px solid var(--border-color); padding-bottom: 1rem; }
        .section-number { font-size: 0.75rem; font-weight: 700; color: var(--accent-color); text-transform: uppercase; letter-spacing: 0.15em; margin-bottom: 0.5rem; display: block; }
        h2.section-title { font-size: 2.2rem; font-weight: 700; letter-spacing: -0.02em; }

        .qa-card { background: var(--card-bg); border: 1px solid var(--border-color); border-radius: 12px; padding: 2.5rem; margin-bottom: 2rem; transition: border-color 0.3s ease; }
        .qa-card:hover { border-color: #d1c8c1; }
        .question { font-weight: 700; font-size: 1.25rem; margin-bottom: 1.5rem; color: var(--text-color); line-height: 1.4; border-left: 3px solid var(--accent-color); padding-left: 1.5rem; }
        .answer { color: var(--secondary-text); font-size: 1.05rem; }
        .answer p { margin-bottom: 1.2rem; }
        .answer p:last-child { margin-bottom: 0; }

        pre { background: var(--code-bg); color: #f5f2f0; padding: 1.5rem; border-radius: 8px; overflow-x: auto; margin: 1.5rem 0; font-size: 0.9rem; line-height: 1.5; border: 1px solid #332d2a; }
        code { font-family: "SFMono-Regular", Consolas, "Liberation Mono", Menlo, monospace; }

        footer { margin-top: 10rem; padding: 6rem 2rem; background: #1a1614; color: #8d7e75; text-align: center; }
        .footer-logo { color: #fff; font-weight: 700; margin-bottom: 1rem; display: block; font-size: 1.2rem; letter-spacing: 0.2em; }
        
        @media (max-width: 600px) {
            h1 { font-size: 2.5rem; }
            .qa-card { padding: 1.5rem; }
            .question { font-size: 1.1rem; }
        }
    </style>
</head>
<body>
<header>
    <div class="logo"><div class="logo-icon"></div> Agentic AI 2026</div>
</header>
<main>
    <div class="hero">
        <span class="badge">Professional Vietnamese Edition</span>
        <h1>Lộ Trình Kỹ Sư Agentic AI</h1>
        <p>Kiến thức nền tảng và 100+ câu hỏi phỏng vấn chuyên sâu để chinh phục kỷ nguyên tác vụ AI.</p>
    </div>
"""

    html_end = """
    <footer>
        <span class="footer-logo">AGENTIC AI 2026</span>
        <p>© 2026 Vietnamese AI Engineering Community. Inspiried by Steel Discipline.</p>
    </footer>
</main>
<script>
    // Smooth scroll offset adjustment if needed
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
        anchor.addEventListener('click', function (e) {
            e.preventDefault();
            const target = document.querySelector(this.getAttribute('href'));
            if (target) {
                window.scrollTo({
                    top: target.offsetTop - 100,
                    behavior: 'smooth'
                });
            }
        });
    });
</script>
</body>
</html>
"""

    # Parse sections and Q&As
    sections = []
    current_section = None
    
    lines = content.split('\n')
    
    # Logic to find the real start of chapters
    start_index = 0
    for idx, line in enumerate(lines):
        if "# CHI TIẾT CÁC CHƯƠNG" in line:
            start_index = idx
            break

    i = start_index
    while i < len(lines):
        line = lines[i].strip()
        
        # Detect section (Chapter) - Look for lines like "| 2 Cơ bản về Python |"
        if line.startswith('|') and re.search(r'\|\s*(\d+)\s+(.*?)\s*\|', line):
            match = re.search(r'\|\s*(\d+)\s+(.*?)\s*\|', line)
            if match:
                num = match.group(1).strip()
                name = match.group(2).strip()
                # Clean name: remove extra whitespace and any trailing numbers
                name = re.sub(r'\s+', ' ', name)
                name = re.sub(r'\s+\d+$', '', name)
                
                # If we encounter a new chapter, finish the previous one
                current_section = {"num": num, "title": name, "qa": []}
                sections.append(current_section)
        
        # Detect Question
        elif re.match(r'^\d+\.\d+\s*Câu hỏi:', line):
            q_text = line.split('Câu hỏi:', 1)[1].strip()
            a_lines = []
            i += 1
            # Look for answer
            while i < len(lines):
                a_line = lines[i].strip()
                if a_line.startswith('Trả lời:'):
                    a_lines.append(a_line.split('Trả lời:', 1)[1].strip())
                    i += 1
                    # Collect following lines until next question or section
                    while i < len(lines):
                        next_line = lines[i].strip()
                        # Detect if next line is a new question or a new chapter
                        if re.match(r'^\d+\.\d+\s*Câu hỏi:', next_line) or (next_line.startswith('|') and re.search(r'\|\s*(\d+)\s+(.*?)\s*\|', next_line)):
                            break
                        if next_line:
                            a_lines.append(next_line)
                        i += 1
                    break
                i += 1
            
            # Format answer content
            answer_content = ""
            in_code = False
            for al in a_lines:
                if al.startswith('```'):
                    if in_code:
                        answer_content += "</code></pre>"
                        in_code = False
                    else:
                        lang = al.replace('```', '').strip()
                        answer_content += f"<pre><code class='language-{lang}'>"
                        in_code = True
                else:
                    if in_code:
                        answer_content += al + "\n"
                    else:
                        # Convert simple bullet points to p tags with some styling if needed
                        if al.startswith('* ') or al.startswith('- '):
                            answer_content += f"<p>• {al[2:]}</p>"
                        else:
                            answer_content += f"<p>{al}</p>"
            
            if current_section:
                current_section["qa"].append({"q": q_text, "a": answer_content})
            continue # Already advanced i

        i += 1

    # Filter out empty sections if any
    sections = [s for s in sections if s["qa"]]

    # Build the HTML body
    body_html = '<div class="grid-toc">'
    for s in sections:
        body_html += f'<a href="#sec-{s["num"]}" class="toc-card"><h3><span>{s["num"].zfill(2)}</span> {s["title"]}</h3><p>{len(s["qa"])} câu hỏi phỏng vấn.</p></a>'
    body_html += '</div>'

    for s in sections:
        body_html += f'<section id="sec-{s["num"]}">'
        body_html += f'<div class="section-header"><span class="section-number">Chương {s["num"]}</span><h2 class="section-title">{s["title"]}</h2></div>'
        body_html += '<div class="qa-container">'
        for qa in s["qa"]:
            body_html += f'<div class="qa-card"><div class="question">{qa["q"]}</div><div class="answer">{qa["a"]}</div></div>'
        body_html += '</div></section>'

    with open(r"e:\SDD-Upgrade\scratch\agentic-ai-roadmap-vi.html", "w", encoding="utf-8") as f:
        f.write(html_start + body_html + html_end)

if __name__ == "__main__":
    markdown_to_html()
    print("Sucessfully updated HTML.")
