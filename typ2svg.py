import argparse
import os
import subprocess
import re
import glob

def get_src(typ_path):
    src = ""
    try:
        with open(typ_path, 'r', encoding='utf-8') as f:
            src = f.read()
    except Exception as e:
        print(f"Warning: Could not read title from {typ_path}: {e}")
    src = src.replace("<", "&amp;")
    src = src.replace("<", "&lt;")
    src = src.replace(">", "&gt;")
    return src

def get_title(typ_path):
    """读取typ文件的第一行获取标题"""
    title = "Untitled"
    try:
        with open(typ_path, 'r', encoding='utf-8') as f:
            first_line = f.readline().strip()
            # 匹配 // 后面的内容
            if first_line.startswith("//"):
                title = first_line.lstrip("/").strip()
    except Exception as e:
        print(f"Warning: Could not read title from {typ_path}: {e}")
    return title

def clean_svgs(directory):
    """删除指定目录下的所有 svg 文件"""
    if not os.path.exists(directory):
        return
    svgs = glob.glob(os.path.join(directory, "*.svg"))
    for svg in svgs:
        try:
            os.remove(svg)
        except OSError as e:
            print(f"Error removing {svg}: {e}")

def natural_sort_key(s):
    """用于文件名的自然排序 (index1, index2, index10)"""
    return [int(text) if text.isdigit() else text.lower()
            for text in re.split('([0-9]+)', s)]

def main():
    parser = argparse.ArgumentParser(description="Compile Typst to SVG and embed in HTML.")
    parser.add_argument("typ_path", help="Path to the .typ file")
    args = parser.parse_args()

    typ_path = args.typ_path
    
    # 1. 计算路径
    # 假设输入是 a/b/index.typ
    # 目标目录是 output/a/b/
    input_dir = os.path.dirname(typ_path)
    if not input_dir: 
        input_dir = "." # 处理当前目录的情况
        
    output_dir = os.path.join("output", input_dir)
    
    # 确保输出目录存在
    os.makedirs(output_dir, exist_ok=True)

    # 2. 获取标题
    title = get_title(typ_path)
    typstsrc = get_src(typ_path)
    print(f"Detected Title: {title}")

    # 3. 预清理：删除旧的 SVG
    print(f"Cleaning old SVGs in {output_dir}...")
    clean_svgs(output_dir)

    # 4. 编译 Typst
    # 构建输出文件模式，例如 output/xxx/xxx/index{0p}.svg
    # 注意：typst 命令行通常使用 index{n}.svg 或 index{p}.svg，这里严格按照你的要求 index{0p}.svg
    output_pattern = os.path.join(output_dir, "index{0p}.svg")
    
    cmd = [
        "typst", "compile", 
        "--root", ".", 
        typ_path, 
        output_pattern
    ]
    
    print(f"Running: {' '.join(cmd)}")
    result = subprocess.run(cmd, capture_output=True, text=True)
    
    if result.returncode != 0:
        print("Typst compilation failed:")
        print(result.stderr)
        return

    # 5. 读取生成的 SVG 并生成 HTML
    # 查找生成的文件，通常是 index1.svg, index2.svg ...
    generated_svgs = glob.glob(os.path.join(output_dir, "index*.svg"))
    
    # 按文件名中的数字进行自然排序
    generated_svgs.sort(key=natural_sort_key)

    if not generated_svgs:
        print("No SVG files were generated.")
        return

    svg_contents = []
    for svg_file in generated_svgs:
        with open(svg_file, 'r', encoding='utf-8') as f:
            content = f.read()
            # 将 SVG 内容包装在 container 中
            div_block = f'<div class="container">\n{content}\n</div><br>'
            svg_contents.append(div_block)
    
    # 拼接所有 SVG 内容
    all_svgs_html = "\n".join(svg_contents)

    # HTML 模板
    html_content = f"""<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <link rel="stylesheet" href="/style3.css">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{title}</title>
    <style>
        body {{ background-color: #eee; padding: 3px 2vw;}}
        .back {{padding:20px 0; background-color: #eee;}}
        .main {{ text-align: center; }}
        .container {{ background-color: white; margin: 3px 0px; display: inline-block;
                box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);}}
        .typst-doc {{ width: 90vw; height: auto; }}
        .back {{ width: 90vw; height: auto; margin: auto;}}
        @media (min-width: 880px) {{ .typst-doc {{  width: 800px; height: auto; }} }}
        @media (min-width: 880px) {{ .back {{  width: 800px; height: auto; }} }}
    </style>
</head>
<body>
<pre class="back"><a href="../">../</a></pre>
<pre style="position:absolute;left:-10000px;top:-10000px;opacity:0;width:1px;height:1px;overflow:hidden;">{typstsrc}</pre>
<div class="main">{all_svgs_html}</div>
<div class="back">
    <hr>
<p id="email">Email: i (at) mistivia (dot) com</p>
<script>
var emailElement = document.getElementById('email');
var base64String = "RW1haWw6IGlAbWlzdGl2aWEuY29tCg==";
var decodedString = atob(base64String);
emailElement.innerHTML = decodedString;
</script>
</div>
<script data-goatcounter="https://blog.mistivia.com:8081/count"
        async src="https://blog.mistivia.com:8081/count.js"></script>
</body>
</html>"""

    # 写入 HTML 文件
    output_html_path = os.path.join(output_dir, "index.html")
    with open(output_html_path, 'w', encoding='utf-8') as f:
        f.write(html_content)
    
    print(f"Generated HTML at: {output_html_path}")

    # 6. 后清理：删除生成的 SVG
    print("Cleaning up intermediate SVG files...")
    clean_svgs(output_dir)
    print("Done.")

if __name__ == "__main__":
    main()