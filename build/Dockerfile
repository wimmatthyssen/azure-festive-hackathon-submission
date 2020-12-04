FROM mcr.microsoft.com/dotnet/sdk:5.0 AS build

COPY src /src 

WORKDIR /src

RUN dotnet build --configuration Release
RUN dotnet publish -c Release -o /app/myapp

# final stage/image
FROM mcr.microsoft.com/dotnet/aspnet:5.0
WORKDIR /app
COPY --from=build /app .
ENTRYPOINT ["./myapp/SantaWishList"]