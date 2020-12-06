```
az ad sp create-for-rbac --name "santawishlist" --sdk-auth --role reader
```

Copy the JSON output from the command.

Create a new secret within your Github repository, and paste in the entire JSON object as the value.

image goes here

Apply terraform

Add the ACR name and password as secrets to your repository with the following names:
- SANTAWISHLIST_ACR
- SANTAWISHLIST_ACR_PASSWORD