# 🏍️ MottuProjeto API

API de gestão de usuários, motos e áreas com autenticação JWT, versionamento, machine learning e health checks.

## 🚀 Tecnologias 

- **.NET 8.0** - Framework principal
- **ASP.NET Core Web API** - API REST
- **Entity Framework Core 8.0** - ORM
- **SQL Server** (Azure SQL Database) - Banco de dados
- **Docker** - Containerização
- **JWT Authentication** - Autenticação segura
- **Swagger/OpenAPI** - Documentação interativa
- **xUnit** - Testes unitários e de integração
- **ML.NET** - Machine Learning
- **Azure DevOps** - CI/CD

```

## 📦 Como Executar

### Pré-requisitos

- .NET 8.0 SDK instalado
- SQL Server (local ou Azure)
- Docker (opcional)

### Localmente

```bash
# Clonar o repositório
git clone https://github.com/seu-usuario/mottu-projeto.git
cd mottu-projeto

# Restaurar dependências
dotnet restore

# Compilar o projeto
dotnet build

# Executar a aplicação
dotnet run
```

Acesse: `https://localhost:7000/swagger` ou `http://localhost:5000/swagger`

### Configurar Connection String

Edite o arquivo `appsettings.json`:

```json
{
  "ConnectionStrings": {
    "Default": "Server=seu-servidor;Database=seu-banco;User Id=seu-usuario;Password=sua-senha;"
  }
}
```

Ou use variável de ambiente:

```bash
# Windows
set ConnectionStrings__Default="Server=..."

# Linux/Mac
export ConnectionStrings__Default="Server=..."
```

### Com Docker

```bash
# Build da imagem
docker build -t mottuprojeto:latest .

# Executar container
docker run -d -p 8080:80 \
  -e "ConnectionStrings__Default=Server=..." \
  --name mottu-api \
  mottuprojeto:latest
```

Acesse: `http://localhost:8080/swagger`

## 🧪 Testes

### Executar todos os testes

```bash
dotnet test --logger "console;verbosity=detailed"
```

### Executar testes com coverage

```bash
dotnet test /p:CollectCoverage=true /p:CoverletOutputFormat=opencover
```

### Testes por projeto

```bash
# Testes gerais
cd MottuProjeto.Tests
dotnet test

# Testes unitários
cd ../MottuProjeto.UnitTests
dotnet test

# Testes de integração
cd ../MottuProjeto.IntegrationTests
dotnet test
```

## 🔐 Autenticação

A API usa autenticação JWT. Para obter um token:

### 1. Login

```http
POST /api/auth/login
Content-Type: application/json

{
  "username": "admin",
  "password": "admin123"
}
```

### 2. Usar o Token

Adicione o header em todas as requisições protegidas:

```
Authorization: Bearer {seu_token_aqui}
```

### Usuário Padrão (SEED)

- **Username:** `admin`
- **Password:** `admin123`
- **Role:** `Admin`

## 📊 Health Checks

A API possui endpoints de monitoramento:

- `/healthz` - Health check básico
- `/healthz/ready` - Readiness check

Retorna status `200 OK` se a aplicação estiver saudável.

## 🎯 Versionamento da API

A API suporta versionamento de 3 formas:

### 1. Via URL
```
GET /api/v1/usuarios
GET /api/v2/usuarios
```

### 2. Via Header
```
GET /api/usuarios
x-api-version: 1.0
```

### 3. Via Query String
```
GET /api/usuarios?api-version=1.0
```

## 🤖 Machine Learning

A API inclui modelos de ML para:

- **MotoRiskModelService** - Avaliação de risco de motos
- **TelemetryRiskService** - Análise de telemetria

Modelos treinados com dados em:
- `data/ml/motosTreino.json`
- `data/ml/telemetria.json`

## 📖 Documentação da API

Acesse o Swagger UI para documentação interativa:

- **Desenvolvimento:** `https://localhost:####/swagger`
- **Produção:** `https://seu-app.azurewebsites.net/swagger`

## 🚢 Deploy

### Azure Web App

A aplicação está configurada para deploy automático via Azure DevOps Pipelines:

1. **CI (Build + Tests)** - Compila e testa o código
2. **CD (Deploy)** - Cria imagem Docker e faz deploy no Azure

### Variáveis de Ambiente (Azure)

Configure no Azure Portal ou via pipeline:

```bash
ConnectionStrings__Default=Server=...
Jwt__Key=sua_chave_secreta
Jwt__Issuer=MottuProjeto
Jwt__Audience=MottuFront
```

## 👥 Equipe

**Sprint 4 - DevOps Tools & Cloud Computing - FIAP**

- RM 556293 Alice Teixeira Caldeira 
- RM 555708 Gustavo Goulart 
- RM 554557 Victor Medeiros


## 📝 Licença

Este projeto foi desenvolvido como parte do curso de DevOps da FIAP.