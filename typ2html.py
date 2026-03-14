import os
import sys
import argparse
import subprocess
from urllib.parse import quote

def parse_arguments():
    parser = argparse.ArgumentParser(description="Compile TeX with cwd change and TEXINPUTS injection.")
    parser.add_argument("filepath", help="The path to the input .tex file (e.g., source/index.tex)")
    return parser.parse_args()

def getcontent(filepath):
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            return f.read()
    except FileNotFoundError:
        print(f"Error: File '{filepath}' not found.")
        sys.exit(1)
    except Exception as e:
        print(f"Error reading file: {e}")
        sys.exit(1)

def get_title_from_tex(filepath):
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            first_line = f.readline().strip()
            if first_line.startswith("//"):
                title = first_line.lstrip("/").strip()
                if not title:
                    print("Error: First line contains '%%' but no title text.")
                    sys.exit(1)
                return title
            else:
                print(f"Error: The first line of '{filepath}' must start with '%% TITLE'. Found: {first_line}")
                sys.exit(1)
    except FileNotFoundError:
        print(f"Error: File '{filepath}' not found.")
        sys.exit(1)
    except Exception as e:
        print(f"Error reading file: {e}")
        sys.exit(1)

def compile_typst(filepath, target_pdf_path):
    cmd = [
        "typst",
        "compile",
        "--root",
        "./",
        filepath,
        target_pdf_path
    ]
    print(" ".join(cmd))

    try:
        result = subprocess.run(
            cmd, 
            stdout=subprocess.PIPE, 
            stderr=subprocess.PIPE, 
            check=True
        )
        print("Compilation successful.")
    except subprocess.CalledProcessError as e:
        print("Error: typst compilation failed.")
        print(e.stdout.decode('utf-8', errors='ignore'))
        print(e.stderr.decode('utf-8', errors='ignore'))
        sys.exit(1)

def generate_html(output_dir, pdf_url, tilte, srctext):
    pdf_url = pdf_url[5:]
    """
    生成包含自动跳转功能的 index.html
    """
    html_path = os.path.join(output_dir, "index.html")
    html_content = f"""<!DOCTYPE html>
<html>
<head>
<title>{tilte}</title>
<meta charset="utf-8">
<link rel="stylesheet" href="/style4.css">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<style>
    .pdf-wrapper {{
        width: 100%;
        height: 80vh;
        margin-bottom: 20px;
    }}
    .pdf-wrapper iframe {{
        width: 100%;
        height: 100%;
        border: none;
        display: block;
    }}
</style>
</head>
<body>
<div style="padding:0px 5px;">
<pre class="back"><a href="../">../</a></pre>
</div>
<pre style="position:absolute;left:-10000px;top:-10000px;opacity:0;width:1px;height:1px;overflow:hidden;">{srctext}</pre>
<div class="pdf-wrapper">
    <iframe src="/pdfjs/web/viewer.html?file={pdf_url}">
        <p><a href="{pdf_url}">{pdf_url}</a></p>
    </iframe>
</div>
<div style="padding:0px 5px;">
<hr>
<p id="email">Email: i (at) mistivia (dot) com</p>
</div>
<script>
var emailElement = document.getElementById('email');
var base64String = "RW1haWw6IGlAbWlzdGl2aWEuY29tCg==";
var decodedString = atob(base64String);
emailElement.innerHTML = decodedString;
</script>
</body>
<script>
var max = function(x, y) {{return x < y ? y : x}};
var seth;
seth = function() {{document.getElementsByClassName('pdf-wrapper')[0].style.height = max(500, document.getElementsByTagName('iframe')[0].contentDocument.getElementById('viewer').scrollHeight) + 80 + 'px'; setTimeout(seth, 1000);}}
setTimeout(seth, 1000);
</script>
</html>
"""
    
    with open(html_path, 'w', encoding='utf-8') as f:
        f.write(html_content)
    print(f"Generated HTML redirect at: {html_path}")

def main():
    args = parse_arguments()
    input_path = args.filepath
    
    title = get_title_from_tex(input_path)
    srctext = getcontent(input_path).replace('<', '&lt;').replace('>', '&gt;')
    print(f"Extracted Title: {title}")

    dir_name = os.path.dirname(input_path)
    
    output_dir = os.path.join("output", dir_name)
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)

    target_pdf_name = f"index.pdf"
    target_pdf_path = os.path.join(output_dir, target_pdf_name)

    compile_typst(input_path, target_pdf_path)

    generate_html(output_dir, '/' + dir_name + '/index.pdf', title, srctext)
    print("Done.")

if __name__ == "__main__":
    main()