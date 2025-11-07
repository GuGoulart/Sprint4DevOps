using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;
using System.Text;
using MottuProjeto.Data;

// ▼ Imports necessários para VERSIONAMENTO
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.ApiExplorer;
using Microsoft.AspNetCore.Mvc.Versioning;
using Microsoft.Extensions.Options;
using Swashbuckle.AspNetCore.SwaggerGen;

var builder = WebApplication.CreateBuilder(args);

// Controllers
builder.Services.AddControllers();

// ML Services
builder.Services.AddSingleton<MottuProjeto.ML.MotoRiskModelService>();
builder.Services.AddSingleton<MottuProjeto.ML.TelemetryRiskService>();

// Swagger + JWT (botão Authorize → Bearer <token>)
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    var jwtSecurityScheme = new OpenApiSecurityScheme
    {
        Scheme = "bearer",
        BearerFormat = "JWT",
        Name = "Authorization",
        In = ParameterLocation.Header,
        Type = SecuritySchemeType.Http,
        Description = "Informe: Bearer {seu_token_jwt}",
        Reference = new OpenApiReference
        {
            Id = JwtBearerDefaults.AuthenticationScheme,
            Type = ReferenceType.SecurityScheme
        }
    };
    c.AddSecurityDefinition(jwtSecurityScheme.Reference.Id, jwtSecurityScheme);
    c.AddSecurityRequirement(new OpenApiSecurityRequirement
    {
        { jwtSecurityScheme, Array.Empty<string>() }
    });
});

// ▼ VERSIONAMENTO DE API
builder.Services.AddApiVersioning(options =>
{
    options.AssumeDefaultVersionWhenUnspecified = true;
    options.DefaultApiVersion = new ApiVersion(1, 0);
    options.ReportApiVersions = true;

    options.ApiVersionReader = ApiVersionReader.Combine(
        new UrlSegmentApiVersionReader(),
        new HeaderApiVersionReader("x-api-version"),
        new QueryStringApiVersionReader("api-version")
    );
});

builder.Services.AddVersionedApiExplorer(options =>
{
    options.GroupNameFormat = "'v'VVV";
    options.SubstituteApiVersionInUrl = true;
});

builder.Services.AddTransient<IConfigureOptions<SwaggerGenOptions>, ConfigureSwaggerOptions>();

// ✅ DbContext (SQL SERVER) — CORRIGIDO!
builder.Services.AddDbContext<AppDbContext>(opt =>
{
    // Prioriza variável de ambiente (para Azure DevOps pipelines)
    var conn = Environment.GetEnvironmentVariable("ConnectionStrings__Default")
               ?? builder.Configuration.GetConnectionString("Default");

    if (string.IsNullOrWhiteSpace(conn))
        throw new InvalidOperationException("Connection string SQL Server não configurada. Configure 'Default' no appsettings.json ou variável de ambiente 'ConnectionStrings__Default'.");

    opt.UseSqlServer(conn); // ✅ SQL SERVER (antes era UseOracle)
});

// JWT
var jwtSection = builder.Configuration.GetSection("Jwt");
var key = Encoding.ASCII.GetBytes(jwtSection["Key"] ?? "CHAVE_SECRETA_DEV");

builder.Services.AddAuthentication(options =>
{
    options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
    options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
})
.AddJwtBearer(options =>
{
    options.RequireHttpsMetadata = false;
    options.SaveToken = true;
    options.TokenValidationParameters = new TokenValidationParameters
    {
        ValidateIssuerSigningKey = true,
        IssuerSigningKey = new SymmetricSecurityKey(key),
        ValidateIssuer = false,
        ValidateAudience = false,
        ClockSkew = TimeSpan.Zero
    };
});

builder.Services.AddAuthorization();

// Health Checks
builder.Services.AddHealthChecks();

var app = builder.Build();

// Swagger (sempre habilitado para facilitar testes)
app.UseSwagger();

var provider = app.Services.GetRequiredService<IApiVersionDescriptionProvider>();
app.UseSwaggerUI(options =>
{
    foreach (var desc in provider.ApiVersionDescriptions)
    {
        options.SwaggerEndpoint($"/swagger/{desc.GroupName}/swagger.json",
            $"MottuProjeto API {desc.GroupName.ToUpper()}");
    }
});

app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();

// SEED simples (admin/admin123)
using (var scope = app.Services.CreateScope())
{
    try
    {
        var ctx = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        
        // ✅ Garante que o banco existe (cria se não existir)
        ctx.Database.EnsureCreated();
        
        if (!ctx.Usuarios.Any())
        {
            ctx.Usuarios.Add(new MottuProjeto.Models.Usuario
            {
                Nome = "Administrador",
                Email = "admin@example.com",
                Username = "admin",
                PasswordHash = "admin123",
                Role = "Admin"
            });
            ctx.SaveChanges();
            
            Console.WriteLine("✅ Usuário admin criado com sucesso!");
        }
    }
    catch (Exception ex)
    {
        Console.WriteLine($"⚠️ Erro no SEED: {ex.Message}");
    }
}

app.Run();

// Habilita WebApplicationFactory<Program> em testes de integração (xUnit)
public partial class Program { }

// ▼ Classe para configurar Swagger dinamicamente por versão
public class ConfigureSwaggerOptions : IConfigureOptions<SwaggerGenOptions>
{
    private readonly IApiVersionDescriptionProvider _provider;

    public ConfigureSwaggerOptions(IApiVersionDescriptionProvider provider)
    {
        _provider = provider;
    }

    public void Configure(SwaggerGenOptions options)
    {
        foreach (var desc in _provider.ApiVersionDescriptions)
        {
            options.SwaggerDoc(desc.GroupName, new OpenApiInfo
            {
                Title = "MottuProjeto API",
                Version = desc.ApiVersion.ToString(),
                Description = "API de gestão de usuários, motos e áreas com autenticação JWT, versionamento e health checks."
            });
        }
    }
}