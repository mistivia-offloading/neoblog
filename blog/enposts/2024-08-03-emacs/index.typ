// Emacs Notes
#import "/template-en.typ":*
#doc-template(
title: "Emacs Notes",
date: "August 3, 2024",
body: [

Recently, I switched my main editor from VS Code to Emacs. Here is a record of the configuration process.

= Basic Settings

Tell Emacs to put temporary files in `/tmp` to avoid polluting the current directory:

```
(setq backup-directory-alist
        `((".*" . ,temporary-file-directory)))
(setq auto-save-file-name-transforms
        `((".*" ,temporary-file-directory t)))
```

Set the font:

```
(set-frame-font "monospace 13" nil t)
(set-fontset-font t 'han "Source Han Sans CN")
```

Enable line numbers:

```
(global-display-line-numbers-mode 1)
```

The menu bar and tool bar are useless in most cases and take up screen space, so hide them. If needed, they can be brought out with `F10`.

```
(menu-bar-mode -1) 
(toggle-scroll-bar -1) 
(tool-bar-mode -1)
```

= Package Management

Add Melpa to Emacs:

```
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
```

Initialize the package manager:

```
(require 'package)
(package-initialize)
```

Then restart Emacs and update the package catalog: `M-x package-refresh-contents`.

Use `M-x package-install` to install the following packages in sequence:

```
- magit
- lsp-mode
- rust-mode
- dired-sidebar
- treesit-auto
- use-package
- yasnippet
- rg
- counsel
- ivy
- lsp-ivy
- projectile
- company
```

To update all installed packages: `M-x list-package RET S-u x`

= Treesit

Enable the built-in `treesit` and use `treesit-auto` for automatic configuration:

```
(require 'treesit)

(use-package treesit-auto
    :config
    (global-treesit-auto-mode))
```

Then install the grammar libraries: `M-x treesit-auto-install-all`

= Typst

The `typst-ts-mode` package is not in Melpa and needs to be installed from Git: `M-x package-vc-install`. The address is:

```
https://git.sr.ht/~meow_king/typst-ts-mode
```

Then compile and install the Typst treesit library. First enter:

```
    M-: (treesit-install-language-grammar 'typst) RET
```

Then enter:

```
https://github.com/uben0/tree-sitter-typst
```

Configuration:

```
(use-package typst-ts-mode
    :custom
    (typst-ts-mode-grammar-location
    (expand-file-name "tree-sitter/libtree-sitter-typst.so"
                        user-emacs-directory)))
```

= Ivy

Ivy is a completion tool for the minibuffer. Some people use Helm, but I find Ivy to be lighter and more concise.

```
(require 'ivy)
(require 'counsel)
(ivy-mode)
(setq ivy-use-virtual-buffers t)
(setq enable-recursive-minibuffers t)
(global-set-key "\C-s" 'swiper)
(global-set-key (kbd "C-c C-r") 'ivy-resume)
(global-set-key (kbd "<f6>") 'ivy-resume)
(global-set-key (kbd "M-x") 'counsel-M-x)
(global-set-key (kbd "C-x C-f") 'counsel-find-file)
(global-set-key (kbd "<f1> f") 'counsel-describe-function)
(global-set-key (kbd "<f1> v") 'counsel-describe-variable)
(global-set-key (kbd "<f1> o") 'counsel-describe-symbol)
(global-set-key (kbd "<f1> l") 'counsel-find-library)
(global-set-key (kbd "<f2> i") 'counsel-info-lookup-symbol)
(global-set-key (kbd "<f2> u") 'counsel-unicode-char)
(global-set-key (kbd "C-c g") 'counsel-git)
(global-set-key (kbd "C-c j") 'counsel-git-grep)
(global-set-key (kbd "C-c k") 'counsel-ag)
(global-set-key (kbd "C-x l") 'counsel-locate)
(global-set-key (kbd "C-S-o") 'counsel-rhythmbox)
(define-key minibuffer-local-map (kbd "C-r") 'counsel-minibuffer-history)
```

= LSP

Here, only the Rust LSP function is installed first:

```
(use-package company)
(use-package rust-mode)
(use-package lsp-mode
    :init
    ;; set prefix for lsp-command-keymap (few alternatives - "C-l", "C-c l")
    (setq lsp-keymap-prefix "C-c l")
    :hook (
            (rust-mode . lsp)
            ;; if you want which-key integration
            (lsp-mode . lsp-enable-which-key-integration))
    :commands lsp)
(use-package lsp-ivy :commands lsp-ivy-workspace-symbol)
```

= Sidebar File Browser

Use `dired-sidebar`:

```
(use-package dired-sidebar
    :bind (("C-x C-n" . dired-sidebar-toggle-sidebar))
    :ensure t
    :commands (dired-sidebar-toggle-sidebar)
    :init
    (add-hook 'dired-sidebar-mode-hook
            (lambda ()
                (unless (file-remote-p default-directory)
                (auto-revert-mode))))
    :config
    (push 'toggle-window-split dired-sidebar-toggle-hidden-commands)
    (push 'rotate-windows dired-sidebar-toggle-hidden-commands)

    (setq dired-sidebar-subtree-line-prefix "__")
    (setq dired-sidebar-theme 'vscode)
    (setq dired-sidebar-use-term-integration t)
    (setq dired-sidebar-use-custom-font t))
```

Then you can use `C-x C-n` to call up the sidebar.

= Projectile

Use `C-c p` to quickly jump to files in a project, similar to Vim's CtrlP:

```
(projectile-mode +1)
;; Recommended keymap prefix on Windows/Linux
(define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map)
```

= Snippet

Use the `yasnippet` plugin:

```
(use-package yasnippet
    :bind
    (("C-c n i" . yas-insert-snippet))  
    :config
    (add-to-list 'yas-snippet-dirs "~/.emacs.d/snippets")
    (yas-global-mode 1))
```

Snippets are saved in the `~/.emacs.d/snippets/{mode_name}/` directory.

= Ripgrep

The `rg` plugin allows for fast text searches within project directories:

```
(require 'rg)
(rg-enable-default-bindings)
```

The most commonly used shortcut is `C-c p f` to search within a Projectile project.

= Magit

The functions of the Magit plugin are quite complex and will not be detailed here. You can refer to the tutorials on the Magit website.

Enable:

```
(require 'magit)
```

= Markdown

Directly load the Markdown mode:

```
(use-package markdown-mode)
```

])
