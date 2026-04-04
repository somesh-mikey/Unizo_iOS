import os
import glob
import re

models_dir = "/Users/user57/Downloads/Unizo_iOS-91b34829bbcafc580c90ec82b20083c30b1c9c45/Unizo_iOS/Data/Models"
files = glob.glob(os.path.join(models_dir, "*.swift"))

for file_path in files:
    with open(file_path, "r") as f:
        content = f.read()
    
    # Skip processing if UIModel
    # But wait, UI models will have `let id: UUID`, so we should rename them to String as well to match DTOs...
    if "import FirebaseFirestoreSwift" not in content and "struct" in content:
        content = content.replace("import Foundation", "import Foundation\nimport FirebaseFirestoreSwift\nimport FirebaseFirestore")
    
    # 2. Replace let id: UUID or var id: UUID with @DocumentID var id: String?
    content = re.sub(r'let\s+id\s*:\s*UUID(\?)?', r'@DocumentID var id: String?', content)
    content = re.sub(r'var\s+id\s*:\s*UUID(\?)?', r'@DocumentID var id: String?', content)
    
    # 3. Replace all remaining UUID with String
    content = re.sub(r'\bUUID\b', 'String', content)

    # 4. Remove case id = "id" from CodingKeys since @DocumentID handles it (if it explicitly has CodingKeys)
    # The DocumentID wrapper makes `id` excluded from the generated CodingKeys anyway, but if there's a custom CodingKey enum:
    content = re.sub(r'case\s+id\s*=\s*"[^"]+"\n?', '', content)
    content = re.sub(r'case\s+id\n?', '', content)

    with open(file_path, "w") as f:
        f.write(content)

print(f"Migrated {len(files)} files successfully.")
