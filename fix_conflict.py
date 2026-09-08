import re

paths = [
    "/var/www/sheba/users/urls.py",
    "/var/www/sheba/users/views.py"
]

for path in paths:
    with open(path, 'r') as f:
        content = f.read()

    # Simple regex to remove git conflict markers and keep both sections
    content = re.sub(r'<<<<<<< Updated upstream\n(.*?)=======\n(.*?)>>>>>>> Stashed changes\n', r'\1\n\2', content, flags=re.DOTALL)
    
    with open(path, 'w') as f:
        f.write(content)

print("Conflicts resolved.")
