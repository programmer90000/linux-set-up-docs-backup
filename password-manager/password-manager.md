Run:
```
keepassxc
```

Click `Create Database`

Set the name to `Passwords`

Click `Continue`

Set the `Database format` to the recommended option

Set the `Encryption Settings` to `Basic`. Do not change any `Advanced` settings

Set the `Decryption Time` to `1.0 sec`

Select `Continue`

Set the `Password` to a strong password different to your user password

Select `Add additional protection...`

Select `Add Key File`

Select `Generate`

Set it to `/home/password-is-admin/.config/keepassxc/passwords.keyx`

Select `Done`

Save the database as `/home/password-is-admin/.config/keepassxc/Passwords.kdbx`

Go to `Settings > Browser integration`

Enable `Browser Integration`

Enable `Brave`

Create a new password

Set the `Title` to `Raindrop`

Set the `Username` to `test`

Set the `Password` to `test`

Set the `URL` to `https://app.raindrop.io/`

Press `Ok`

Open `Brave browser`

Go to the `Extensions` page

Install `KeePassXC-Browser` by `https://keepassxc.org/`. The publisher should have a tick before the name. Hovering over the name should reveal the message: `Created by the owner of the listed website. The publisher has a good record with no history of violations.`

Click `Add to Brave`

Click on the extension

Click `Connect`

Set the name of the connection to `brave-browser`

Open `Raindrop`

This should open `Keepassxc`. Enable `Remember`. Click `Allow Selected`

When asked to save the password in Brave, select `Never`

