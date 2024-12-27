# Candyshop

❤️ [Please sponsor me if you like this package](https://github.com/sponsors/konrad1977)

Candyshop is a small package for Emacs and OSX users. It will automatically setup the transparency for Emacs and hide icons on the desktop and also hide all active windows except for Emacs.

```emacs-lisp
(use-package candyshop
  :ensure nil
  :hook (after-init . candyshop-mode)
  :config
  (setq candyshop-alpha-values '(100 90)))
```

<p align="center">
  <img src="https://github.com/konrad1977/candyshop/blob/main/screenshot/dashboard.png" 
  alt="Candy shop dashboard screenshot. vs"/>
</p>
