# Stage 1: Build
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copiar .csproj e restaurar dependências
COPY ["MottuProjeto.csproj", "./"]
RUN dotnet restore "MottuProjeto.csproj"

# Copiar todo o código fonte
COPY . .

# Build do projeto
RUN dotnet build "MottuProjeto.csproj" -c Release -o /app/build

# Stage 2: Publish
FROM build AS publish
RUN dotnet publish "MottuProjeto.csproj" -c Release -o /app/publish /p:UseAppHost=false

# Stage 3: Runtime
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app

# Expor portas HTTP e HTTPS
EXPOSE 80
EXPOSE 443

# Copiar arquivos publicados do stage anterior
COPY --from=publish /app/publish .

# Definir ponto de entrada da aplicação
ENTRYPOINT ["dotnet", "MottuProjeto.dll"]