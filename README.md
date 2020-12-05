```
az ad sp create-for-rbac --name "santawishlist" --sdk-auth --role reader
```

Copy the JSON output from the command.

Create a new secret within your Github repository, and paste in the entire JSON object as the value.

image goes here

Apply terraform