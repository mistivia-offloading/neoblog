import re
import sys
import subprocess

def replace_markdown_links_in_file(content):
    # pattern_inline_link = re.compile(r'\[([^\]]+?)\]\((.+?)\)')
    pattern_image_link = re.compile(r'!\[([^\]]+?)\]\((.+?)\)')
    pattern_new_link = re.compile(r'~\[([^\]]+?)\]\((.+?)\)')
    content = pattern_new_link.sub(r'<a href="\2" target="_blank">\1</a>', content)
    content = pattern_image_link.sub(r'<a href="\2" target="_blank"><img src="\2" alt="\1" style="max-width:300px;max-height:300px;"></a>', content)
    # content = pattern_inline_link.sub(r'<a href="\2">\1</a>', content)
    return content

template = """
<!DOCTYPE html>
<html>
<head>
<title>{}</title>
<meta charset="utf-8">
<link rel="stylesheet" href="/style3.css">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
</head>
<body>
<pre class="back"><a href="../">../</a></pre>

{}

<hr>
<p id="email">Email: i (at) mistivia (dot) com</p>
<script>
var emailElement = document.getElementById('email');
var base64String = "RW1haWw6IGlAbWlzdGl2aWEuY29tCg==";
var decodedString = atob(base64String);
emailElement.innerHTML = decodedString;
</script>
</body>
</html>
"""

def markdown_convert(title, body):
    html_title = f"<h1>{title}</h1>"
    try:
        result = subprocess.run(
            ["markdown"],
            input=body,
            capture_output=True,
            text=True,
            check=True
        )
        html_body = result.stdout.strip()
        
    except FileNotFoundError:
        return "error: cannot find 'makrdown' command"
    
    except subprocess.CalledProcessError as e:
        return (f"error:：Markdown convert cmd failed (exit code: {e.returncode})."
                f"\nerr msg: {e.stderr}")
    full_html_output = f"{html_title}\n{html_body}"
    return full_html_output

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage：python your_script_name.py <input_file_path>")
        sys.exit(1)
    input_file = sys.argv[1]
    with open(input_file, 'r', encoding='utf-8') as f:
        content = f.read()
    # content = content.replace('<', '&lt;')
    # content = content.replace('>', '&gt;')
    content = replace_markdown_links_in_file(content)
    title = content.splitlines(1)[0].strip()
    body = ''.join(content.splitlines(1)[2:])
    html = markdown_convert(title, body)
    print(template.format(title, html))

