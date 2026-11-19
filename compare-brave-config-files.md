I have installed `meld` using `sudo apt install meld`. However, I haven't added it to the docs. I may want to

In the terminal, run:
```
meld
```

This will open a GUI app.

Select `Folder`

Inside the first box, open `.config/BraveSoftware/Brave-Browser`

Inside the second box, open `brave-orignial-files/BraveSoftware/Brave-Browser`

Select `Compare`

Click the button with 3 lines at the top right, `Preferences`

Select `File Filters`

Make a new filter with the name `Brave`

Add the following line to the filter:
```
CertificateRevocation BudgetDatabase Crash?Reports Crowd?Deny BraveWallet AdBlock?Custom?Resources AutofillStrikeDatabase ClientCertificates
```

Note that I can't ignore specific subdirs
