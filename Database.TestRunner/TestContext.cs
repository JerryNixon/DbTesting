using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;

namespace Database.TestRunner
{
    internal class TestContext : ContextBase
    {
        public DbSet<TestModel>? SimpleModels { private get; set; }

        public IEnumerable<object[]> ListTests()
            => Set<TestModel>()
            .FromSqlRaw(@"SELECT CONCAT(s.name, '.', p.name) AS Test
	                      FROM sys.procedures AS p
	                      JOIN sys.schemas AS s ON p.schema_id = s.schema_id
	                      WHERE s.name = 'Tests'")
            .Select(x => new[] { x.Test ?? string.Empty })
            .ToArray();
    }

    internal class TestModel
    {
        [Key]
        public string? Test { get; set; }
    }
}