using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using Xunit;

namespace Database.TestRunner
{
    public class UnitTests : IDisposable
    {
        protected readonly DbContext _context = new TestContext();

        public UnitTests()
            => _context.Database.BeginTransaction();

        public void Dispose()
            => _context.Database.RollbackTransaction();

        public static IEnumerable<object[]> ListTests()
            => new TestContext().ListTests();

        [Fact]
        public void DbContext_CanConnect()
            => Assert.True(_context.Database.CanConnect());

        [Fact]
        public void ListTests_NotEmpty()
            => Assert.NotEmpty(ListTests());

        [Theory]
        [MemberData(nameof(ListTests))]
        public async Task SqlTest(string sql)
            => await _context.Database.ExecuteSqlRawAsync(sql);
    }
}