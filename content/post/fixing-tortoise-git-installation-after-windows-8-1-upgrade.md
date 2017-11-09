---
author: "Rodrigo Dumont"
date: 2013-12-17
linktitle: Fixing Tortoise Git installation after Windows 8.1 upgrade
title: Fixing Tortoise Git installation after Windows 8.1 upgrade
tags: [ git tortoise-git windows ]
highlight: true
---

So, after upgrading from Windows 8 to Windows 8.1, everything seemed smooth for a while. Until I realized that **Tortoise Git had stopped working**. It just would't open, not through any shortcut or method. The worse is, when I tried to uninstall or repair it, I just got an error message saying:

```
There is a problem with this Windows Installer package. A DLL required for this install to complete could not be run. Contact your support personnel or package vendor.
```

<!-- more -->

I must admit this gave me a real hard time, but after a couple of hours I finally got it working. To save you some time, here is what I did:

1. Open `regedit.exe`.
2. Find (`Ctrl+F`) every occurrence of "Tortoise" in the registry and delete it. I checked "Look at" Keys, Values and Data.
3. Delete your TortoiseGit installation folder. Mine was `C:\Program Files\TortoiseGit`. Note that you might not be able to remove some files because they are in use, but it's alright to keep those.
4. Run the TortoiseGit installer again

After these steps, everything went back to normal. There might have been an an easier way to get around this, but this is how I achieved it. Hope this saves you some time!
