import os
import sys
import argparse
import subprocess
import shutil
from urllib.parse import quote

def parse_arguments():
    parser = argparse.ArgumentParser(description="Compile TeX with cwd change and TEXINPUTS injection.")
    parser.add_argument("filepath", help="The path to the input .tex file (e.g., source/index.tex)")
    return parser.parse_args()

def getcontent(filepath):
    """
    读取 tex 文件的第一行，提取 %% 后的内容作为标题
    """
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
    """
    读取 tex 文件的第一行，提取 %% 后的内容作为标题
    """
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            first_line = f.readline().strip()
            if first_line.startswith("%%"):
                title = first_line.lstrip("%").strip()
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

def compile_tex(filepath, output_dir):
    """
    切换到 tex 文件所在目录，注入 TEXINPUTS 并调用 xelatex
    """
    # 1. 准备路径
    abs_output_dir = os.path.abspath(output_dir)
    source_dir = os.path.dirname(filepath)
    file_name = os.path.basename(filepath)
    
    # 记录脚本运行时的根目录 (Project Root)
    project_root = os.getcwd()

    if not source_dir:
        source_dir = "."

    # 2. 设置环境变量 TEXINPUTS
    env = os.environ.copy()
    
    # 获取原本的 TEXINPUTS (如果有)
    original_texinputs = env.get('TEXINPUTS', '')
    
    # 构造新的 TEXINPUTS
    # 格式: [项目根目录] + [系统分隔符] + [原有配置(如果有)]
    # 注意: 即使原有配置为空，末尾必须保留一个分隔符 (os.pathsep)，
    # 这样 TeX 编译器才会继续搜索系统默认的标准库 (如 article.cls)
    if original_texinputs:
        new_texinputs = f"{project_root}{os.pathsep}{original_texinputs}"
    else:
        new_texinputs = f"{project_root}{os.pathsep}"
        
    env['TEXINPUTS'] = new_texinputs

    print(f"Changing working directory to: '{source_dir}'")
    print(f"Setting TEXINPUTS to: '{new_texinputs}'")
    print(f"Compiling '{file_name}' using xelatex...")
    
    cmd = [
        "xetex",
        "-interaction=nonstopmode",
        f"-output-directory={abs_output_dir}",
        file_name
    ]

    try:
        # 3. 执行编译
        # cwd=source_dir: 切换工作目录到 tex 文件所在位置
        # env=env: 注入包含新 TEXINPUTS 的环境变量
        result = subprocess.run(
            cmd, 
            cwd=source_dir, 
            env=env,
            stdout=subprocess.PIPE, 
            stderr=subprocess.PIPE, 
            check=True
        )
        print("Compilation successful.")
    except subprocess.CalledProcessError as e:
        print("Error: xelatex compilation failed.")
        print(e.stdout.decode('utf-8', errors='ignore'))
        sys.exit(1)

def generate_html(output_dir, pdf_filename, srctext):
    """
    生成包含自动跳转功能的 index.html
    """
    html_path = os.path.join(output_dir, "index.html")
    pdf_url = quote(f"./{pdf_filename}")
    
    html_content = f"""<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="refresh" content="0; url={pdf_url}">
    <title>Redirecting...</title>
</head>
<body>
    <p>If you are not redirected automatically, follow this <a href="{pdf_url}">link to the PDF</a>.</p>
</body>
</html>
"""
    
    with open(html_path, 'w', encoding='utf-8') as f:
        f.write(html_content)
    print(f"Generated HTML redirect at: {html_path}")

def main():
    args = parse_arguments()
    input_path = args.filepath
    
    title = get_title_from_tex(input_path)
    srctext = getcontent().replace('<', '&lt;').replace('>', '&gt;')
    print(f"Extracted Title: {title}")

    dir_name = os.path.dirname(input_path)
    base_name = os.path.basename(input_path)
    base_name_no_ext = os.path.splitext(base_name)[0]
    
    output_dir = os.path.join("output", dir_name)
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)

    compile_tex(input_path, output_dir)

    original_pdf_path = os.path.join(output_dir, f"{base_name_no_ext}.pdf")
    target_pdf_name = f"{title}.pdf"
    target_pdf_path = os.path.join(output_dir, target_pdf_name)

    if os.path.exists(original_pdf_path):
        if os.path.exists(target_pdf_path):
            os.remove(target_pdf_path)
        os.rename(original_pdf_path, target_pdf_path)
        print(f"Renamed PDF to: {target_pdf_path}")
    else:
        print(f"Error: Expected output file '{original_pdf_path}' not found.")
        sys.exit(1)

    generate_html(output_dir, target_pdf_name, srctext)
    print("Done.")

if __name__ == "__main__":
    main()