import os
import re
import yaml

def extract_skill_info(file_path):
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
            # Extract YAML frontmatter
            match = re.search(r'^---\s*\n(.*?)\n---', content, re.DOTALL)
            if match:
                yaml_text = match.group(1)
                name_match = re.search(r'name:\s*(.*)', yaml_text)
                desc_match = re.search(r'description:\s*"(.*)"', yaml_text)
                if not desc_match:
                    desc_match = re.search(r'description:\s*(.*)', yaml_text)
                
                if name_match:
                    name = name_match.group(1).strip().strip('"').strip("'")
                    desc = desc_match.group(1).strip().strip('"').strip("'") if desc_match else "No description"
                    command = f"/{name}" if not name.startswith('/') else name
                    return command, desc
    except Exception:
        return None, None
    return None, None

def main():
    skills_dir = r'E:\SDD\.claude\skills'
    commands = []
    
    for root, dirs, files in os.walk(skills_dir):
        if 'SKILL.md' in files:
            file_path = os.path.join(root, 'SKILL.md')
            cmd, desc = extract_skill_info(file_path)
            if cmd:
                commands.append((cmd, desc))
    
    # Sort commands alphabetically
    commands.sort()
    
    with open(r'E:\SDD\DANH_SACH_LENH.md', 'w', encoding='utf-8') as f:
        f.write("# 📜 Danh sách toàn bộ Lệnh Command trong SDD\n\n")
        f.write("Đây là danh sách đầy đủ các lệnh Slash Command được trích xuất từ hệ thống Skills của SDD. Bạn có thể sử dụng bất kỳ lệnh nào bằng cách gõ `/tên_lệnh` trong terminal.\n\n")
        f.write("| Lệnh (Command) | Mô tả hoạt động |\n")
        f.write("| :--- | :--- |\n")
        for cmd, desc in commands:
            # Clean description of newlines for table
            clean_desc = str(desc).replace('\n', ' ').replace('\r', '')
            f.write(f"| `{cmd}` | {clean_desc} |\n")

if __name__ == "__main__":
    main()
