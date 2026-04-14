import os
import yaml

def extract_skill_info(file_path):
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
            
        # Split by frontmatter delimiters
        parts = content.split('---')
        if len(parts) >= 3:
            # The first part might be empty if the file starts with ---
            # So yaml_content is likely parts[1]
            yaml_content = parts[1]
            data = yaml.safe_load(yaml_content)
            
            if isinstance(data, dict):
                name = data.get('name')
                desc = data.get('description')
                
                if name and desc:
                    desc = str(desc).strip().replace('\n', ' ')
                    return str(name).strip(), desc
    except Exception as e:
        # print(f"Error parsing {file_path}: {e}")
        pass
        
    return None

def main():
    skills_dir = r'E:\SDD\.claude\skills'
    commands = []
    skipped = []

    for root, dirs, files in os.walk(skills_dir):
        if 'SKILL.md' in files:
            file_path = os.path.join(root, 'SKILL.md')
            info = extract_skill_info(file_path)
            if info:
                commands.append(info)
            else:
                skipped.append(file_path)

    # Sort by command name
    commands.sort(key=lambda x: x[0])

    output_file = r'E:\SDD\DANH_SACH_LENH.md'
    with open(output_file, 'w', encoding='utf-8') as f:
        f.write("# 📜 Danh sách toàn bộ Lệnh Command trong SDD\n\n")
        f.write(f"Đây là danh sách đầy đủ các lệnh Slash Command được trích xuất từ hệ thống Skills của SDD ({len(commands)} lệnh).\n")
        f.write("Bạn có thể sử dụng bất kỳ lệnh nào bằng cách gõ `/tên_lệnh` trong terminal.\n\n")
        f.write("| Lệnh (Command) | Mô tả hoạt động |\n")
        f.write("| :--- | :--- |\n")
        for name, desc in commands:
            f.write(f"| `/{name}` | {desc} |\n")

    print(f"Report: Found {len(commands)} commands.")
    if skipped:
        print(f"Warning: Skipped {len(skipped)} files due to missing/invalid frontmatter.")
        with open(r'E:\SDD\scripts\skipped_skills.log', 'w', encoding='utf-8') as log_f:
            for s in skipped:
                log_f.write(f"{s}\n")

if __name__ == "__main__":
    main()
