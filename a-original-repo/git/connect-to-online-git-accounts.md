# GitHub

1. Go to `Settings > SSH and GPG keys`
2. Click `New SSH key`
3. Set the `Title` to `debian`
4. Set the `Key type` to `Authentication key`
5. Paste your public key
6. Run the following command to test the connection:
```
ssh -T git@github.com
```
You should recieve the message:
```
Hi programmer90000! You've successfully authenticated, but GitHub does not provide shell access.
```

# GitLab

1. Click on your user profile icon
2. Click `Preferences`
3. Click `Access > SSH Keys`
4. Select `Add new key`
5. Paste your public key
6. Set the `Title` to `debian`
7. Set the `Usage type` to `Authentication & Signing`
8. Remove the `Expiration date`
9. Paste your public key
10. Run the following command to test the connection:
```
ssh -T git@gitlab.com
```
You should recieve the message:
```
Welcome to GitLab, @programmer90000!
```

# BitBucket:

1. Go to `Settings > Security > SSH keys`
2. Select `Add key`
3. Set the `Name` to `debian`
4. Paste your public key
5. Set the `Expiry` to `No expiry`
6. Select "Add key"
7. Run the following command to test the connection:
```
ssh -T git@bitbucket.org
```
You should recieve the message:
```
authenticated via ssh key.

You can use git to connect to Bitbucket. Shell access is disabled
```