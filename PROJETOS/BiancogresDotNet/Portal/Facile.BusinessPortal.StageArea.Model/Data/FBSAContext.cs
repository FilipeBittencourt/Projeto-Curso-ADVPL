using System.Linq;
using Microsoft.EntityFrameworkCore;

namespace Facile.BusinessPortal.StageArea.Model
{
    public class FBSAContext : DbContext
    {
        public FBSAContext(DbContextOptions<FBSAContext> options) : base(options)
        {
        }
        
        #region CLASSES DO MODELO

        //GERAL
        public DbSet<EmpresaInterface> EmpresaInterface { get; set; }
        public DbSet<ProcessoEmpresa> ProcessoEmpresa { get; set; }
        public DbSet<LogIntegracao> LogIntegracao { get; set; }

        //PORTAL DE CLIENTES       
        public DbSet<Sacado> Sacado { get; set; }
        public DbSet<Boleto> Boleto { get; set; }


        //PORTAL DE FORNECEDOR
        public DbSet<Fornecedor> Fornecedor { get; set; }
        public DbSet<TituloPagar> TituloPagar { get; set; }

        public DbSet<Antecipacao> Antecipacao { get; set; }
        public DbSet<AntecipacaoItem> AntecipacaoItem { get; set; }

        public DbSet<TaxaAntecipacao> TaxaAntecipacao { get; set; }


        public DbSet<PedidoCompra> PedidoCompra { get; set; }
        public DbSet<NotaFiscalCompra> NotaFiscalCompra { get; set; }

        public DbSet<Transportadora> Transportadora { get; set; }

        public DbSet<Atendimento> Atendimento { get; set; }
        public DbSet<AtendimentoMedicao> AtendimentoMedicao { get; set; }

        #endregion

        #region SETUP

        protected override void OnModelCreating(ModelBuilder builder)
        {
            base.OnModelCreating(builder);

            foreach (var relationship in builder.Model.GetEntityTypes().SelectMany(e => e.GetForeignKeys()))
            {
                relationship.DeleteBehavior = DeleteBehavior.Restrict;
            }

            //INDICES UNICOS
            builder.Entity<Sacado>().HasIndex(u => new { u.EmpresaID, u.ChaveUnica }).IsUnique();
            builder.Entity<Boleto>().HasIndex(u => new { u.EmpresaID, u.ChaveUnica }).IsUnique();

            builder.Entity<Sacado>().HasIndex(u => new { u.EmpresaID, u.UnidadeID, u.CPFCNPJ }).IsUnique();

            builder.Entity<Fornecedor>().HasIndex(u => new { u.EmpresaID, u.ChaveUnica }).IsUnique();
            builder.Entity<TituloPagar>().HasIndex(u => new { u.EmpresaID, u.ChaveUnica, u.Deletado }).IsUnique();
            //builder.Entity<Fornecedor>().HasIndex(u => new { u.EmpresaID, u.UnidadeID, u.CPFCNPJ }).IsUnique();
        }

        #endregion SETUP
    }
}
