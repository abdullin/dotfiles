(require 'package)

; List the packages you want
(setq package-list '(evil
                     evil-leader))

; Add Melpa as the default Emacs Package repository
; only contains a very limited number of packages
(add-to-list 'package-archives
             '("melpa" . "http://melpa.milkbox.net/packages/") t)

; Activate all the packages (in particular autoloads)
(package-initialize)

; Update your local package index
(unless package-archive-contents
  (package-refresh-contents))

; Install all missing packages
(dolist (package package-list)
  (unless (package-installed-p package)
    (package-install package)))

(require 'evil)
(evil-mode t)

(require 'evil-leader)
(global-evil-leader-mode)
(evil-leader/set-leader ",")
(evil-leader/set-key
  "b" 'switch-to-buffer
  "w" 'save-buffer
  "," 'mode-line-other-buffer)

;; Move custom stuff to a separate file
(setq custom-file "~/.emacs.d/custom.el")
(load custom-file)



;; I know what the scratch is for
(setq initial-scratch-message "")

;; don't show the startup help screen
(setq inhibit-startup-screen t)

;; disable alarm bell beep
(setq visible-bell t)
;; flash on OSX looks ugly
(setq ring-bell-function 'ignore)
;; remove some clutter
(add-to-list 'default-frame-alist '(vertical-scroll-bars . nil))
(add-to-list 'default-frame-alist '(left-fringe . 0))
(add-to-list 'default-frame-alist '(right-fringe . 0))
(add-to-list 'default-frame-alist '(menu-bar-lines . 0))
(add-to-list 'default-frame-alist '(tool-bar-lines . 0))


;; enable auto-fill
(global-set-key (kbd "C-c q") 'auto-fill-mode)


;; When file wasn’t modified, reload changes automatically:
(global-auto-revert-mode t)


;; Set environment coding system to UTF8:
(set-language-environment "UTF-8")

;; just follow symlink and open the actual file
(setq vc-follow-symlinks t)

;; Enable Interactive DO

(add-hook 'ido-setup-hook (lambda ()
                (setq ido-enable-flex-matching t)))


; Use IDO for both buffer and file completion and ido-everywhere to t
(setq ido-everywhere t)
(setq ido-max-directory-size 100000)
(ido-mode (quote both))
; Use the current window when visiting files and buffers with ido
(setq ido-default-file-method 'selected-window)
(setq ido-default-buffer-method 'selected-window)


(ido-mode t)


;; org-mode --------------------
;; Make org-mode look pretty

(require 'org)
(setq org-startup-indented t)
(setq org-hide-leading-stars t)
(setq org-odd-level-only t)
(setq org-indent-mode t)

;; Default for org, txt and archive files
(add-to-list 'auto-mode-alist '("\\.\\(org\\)$" . org-mode))
(setq org-directory "~/org")

;; Use IDO for both buffer and file completion and ido-everywhere to t

(setq org-completion-use-ido t)


;; mode line settings
(column-number-mode t)
(line-number-mode t)
(size-indication-mode t)

;; set your desired tab width
(setq-default indicate-empty-lines t)


;; Auto-save never really worked for me:
(setq make-backup-files nil)
(setq auto-save-default nil)

;; y is shorter than yes:
(fset 'yes-or-no-p 'y-or-n-p)
