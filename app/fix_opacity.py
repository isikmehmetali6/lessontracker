import os
import re

def fix_opacity(root_dir):
    for root, dirs, files in os.walk(root_dir):
        for file in files:
            if file.endswith('.dart'):
                file_path = os.path.join(root, file)
                with open(file_path, 'r', encoding='utf-8') as f:
                    content = f.read()

                # Regex to find .withOpacity(value)
                # It handles cases like .withOpacity(0.5) or .withOpacity(variable)
                # Does NOT handle nested matching or new lines well, but usually withOpacity is single line.
                pattern = r'\.withOpacity\(([^)]+)\)'
                
                def replacement(match):
                    val = match.group(1).strip()
                    return f'.withValues(alpha: {val})'

                new_content = re.sub(pattern, replacement, content)

                if new_content != content:
                    print(f"Fixing {file_path}")
                    with open(file_path, 'w', encoding='utf-8') as f:
                        f.write(new_content)

if __name__ == "__main__":
    fix_opacity('./lib')
