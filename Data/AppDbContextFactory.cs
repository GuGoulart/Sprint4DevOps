using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Design;
using Microsoft.Extensions.Configuration;

namespace MottuProjeto.Data
{
    /// <summary>
    /// Factory para criar instâncias do AppDbContext em tempo de design (migrations).
    /// Usado pelo comando 'dotnet ef migrations add'.
    /// </summary>
    public class AppDbContextFactory : IDesignTimeDbContextFactory<AppDbContext>
    {
        public AppDbContext CreateDbContext(string[] args)
        {
            // Configuração para ler do appsettings.json
            var configuration = new ConfigurationBuilder()
                .SetBasePath(Directory.GetCurrentDirectory())
                .AddJsonFile("appsettings.json", optional: false, reloadOnChange: true)
                .AddJsonFile("appsettings.Development.json", optional: true)
                .AddEnvironmentVariables()
                .Build();

            var optionsBuilder = new DbContextOptionsBuilder<AppDbContext>();

            // Obter connection string (prioriza variável de ambiente)
            var connectionString = Environment.GetEnvironmentVariable("ConnectionStrings__Default")
                                   ?? configuration.GetConnectionString("Default");

            if (string.IsNullOrWhiteSpace(connectionString))
            {
                throw new InvalidOperationException(
                    "Connection string 'Default' não encontrada. " +
                    "Configure no appsettings.json ou na variável de ambiente 'ConnectionStrings__Default'.");
            }

            // ✅ Usar SQL Server (antes era UseOracle)
            optionsBuilder.UseSqlServer(connectionString);

            return new AppDbContext(optionsBuilder.Options);
        }
    }
}