using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;

namespace Database.TestRunner
{
    internal abstract class ContextBase : DbContext
    {
        protected override void OnConfiguring(DbContextOptionsBuilder options)
            => options.UseSqlServer(GetConnectionString());

        private static string GetConnectionString()
            => new ConfigurationBuilder()
            .AddJsonFile("appsettings.json")
            .Build()["ConnectionStrings:Database"];
    }
}