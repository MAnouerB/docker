# Étape 1 : Image de base pour l'exécution (runtime seulement)
# Image légère pour exécuter l'app ASP.NET Core
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
# Définit le dossier de travail dans le conteneur
WORKDIR /app
# Expose le port 80 (HTTP)
EXPOSE 80

# Étape 2 : Image de build (SDK complet)
# Image avec le SDK pour compiler et publier l'app
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
# Définit le dossier de travail pour le build
WORKDIR /src
# Copie le fichier projet dans le conteneur
COPY ["AspNetCoreOnDocker.csproj", "."]
# Restaure les dépendances NuGet
RUN dotnet restore "AspNetCoreOnDocker.csproj"
# Copie tout le code source dans le conteneur
COPY . .
# Compile et publie l'app dans /app/publish
RUN dotnet publish "AspNetCoreOnDocker.csproj" -c Release -o /app/publish

# Étape 3 : Création de l'image finale à partir de l'image de base
# Repart de l'image runtime légère
FROM base AS final
# Définit le dossier de travail final
WORKDIR /app
# Expose le port 8050 pour la version finale
EXPOSE 8050
# Configure Kestrel pour écouter sur 8050
ENV ASPNETCORE_URLS=http://+:8050
# Copie les fichiers publiés depuis l'étape build
COPY --from=build /app/publish .
# Commande de démarrage du conteneur
ENTRYPOINT ["dotnet", "AspNetCoreOnDocker.dll"]
