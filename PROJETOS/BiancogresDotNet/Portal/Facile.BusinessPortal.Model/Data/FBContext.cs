using System.Linq;
using Microsoft.EntityFrameworkCore;
using Facile.BusinessPortal.Model;
using Facile.BusinessPortal.Model.Compra.Servico;
using Microsoft.AspNetCore.Identity.EntityFrameworkCore;

namespace Facile.BusinessPortal.Model
{
    public class FBContext : IdentityDbContext<ApplicationUser>
    {
        public FBContext(DbContextOptions<FBContext> options) : base(options)
        {
        }

        #region CLASSES DO MODELO

        //TABELAS ADMIN E CONFIGURACAO
        public DbSet<LogApi> LogApi { get; set; }
        public DbSet<LogApiHistorico> LogApiHistorico { get; set; }
        public DbSet<Theme> Theme { get; set; }


        //MODELO GERAL PARA TODAS AS EMPRESAS
        public DbSet<Empresa> Empresa { get; set; }
        public DbSet<Unidade> Unidade { get; set; }
        public DbSet<Banco> Banco { get; set; }

        
        //MODELO DE ACESSO
        public DbSet<PerfilEmpresa> PerfilEmpresa { get; set; }
        public DbSet<Usuario> Usuario { get; set; }
        public DbSet<GrupoUsuario> GrupoUsuario { get; set; }
        public DbSet<Menu> Menu { get; set; }
        public DbSet<Acao> Acao { get; set; }
        public DbSet<MenuAcao> MenuAcao { get; set; }
        public DbSet<Permissao> Permissao { get; set; }
        public DbSet<Modulo> Modulo { get; set; }
       // public DbSet<AccessToken> AccessToken { get; set; }
        public DbSet<Parametro> Parametro { get; set; }

        //PORTAL DE CLIENTES
        public DbSet<UsuarioCliente> UsuarioSacado { get; set; }
        public DbSet<ContaBancaria> ContaBancaria { get; set; }
        public DbSet<Cedente> Cedente { get; set; }
        public DbSet<Sacado> Sacado { get; set; }
        public DbSet<GrupoSacado> GrupoSacado { get; set; }
        public DbSet<Boleto> Boleto { get; set; }
        public DbSet<Lote> Lote { get; set; }
        public DbSet<BoletoEvento> BoletoEvento { get; set; }

        //PORTAL DE CLIENTES - CONFIGURACOES
        public DbSet<ConfiguracaoArquivo> ConfiguracaoArquivo { get; set; }
        public DbSet<Mail> Mail { get; set; }
        public DbSet<LayoutEmail> LayoutEmail { get; set; }
        public DbSet<BancoAuth> BancoAuth { get; set; }

        //GERACAO E PROCESSAMENTO DE ARQUIVOS CNAB
        public DbSet<Arquivo> Arquivo { get; set; }
        public DbSet<Registro> Registro { get; set; }


        //PORTAL DE FORNECEDOR
        public DbSet<UsuarioFornecedor> UsuarioFornecedor { get; set; }
        public DbSet<Fornecedor> Fornecedor { get; set; }
        public DbSet<Antecipacao> Antecipacao { get; set; }
        public DbSet<AntecipacaoItem> AntecipacaoItem { get; set; }
        public DbSet<DocumentoPagar> DocumentoPagar { get; set; }
        public DbSet<TituloPagar> TituloPagar { get; set; }
        public DbSet<TaxaAntecipacao> TaxaAntecipacao { get; set; }
        public DbSet<AntecipacaoHistorico> AntecipacaoHistorico { get; set; }
        public DbSet<FornecedorDocumento> FornecedorDocumento { get; set; }


        public DbSet<Token> Token { get; set; }

        public DbSet<UsuarioPessoa> UsuarioPessoa { get; set; }
        public DbSet<UsuarioGrupo> UsuarioGrupo { get; set; }

        public DbSet<Atendimento> Atendimento { get; set; }
        public DbSet<AtendimentoMedicao> AtendimentoMedicao { get; set; }
        public DbSet<AtendimentoHistorico> AtendimentoHistorico { get; set; }


        public DbSet<Aplicacao> Aplicacao { get; set; }
        public DbSet<Armazem> Armazem { get; set; }
        public DbSet<ClasseValor> ClasseValor { get; set; }
        public DbSet<Driver> Driver { get; set; }
        public DbSet<PrioridadeServico> PrioridadeServico { get; set; }
        public DbSet<Produto> Produto { get; set; }
        public DbSet<SolicitacaoServico> SolicitacaoServico { get; set; }
        public DbSet<SolicitacaoServicoFornecedor> SolicitacaoServicoFornecedor { get; set; }
        public DbSet<SolicitacaoServicoFornecedorVisitante> SolicitacaoServicoFornecedorVisitante { get; set; }
        public DbSet<SolicitacaoServicoItem> SolicitacaoServicoItem { get; set; }
        public DbSet<TAG> TAG { get; set; }
        public DbSet<SolicitacaoServicoCotacao> SolicitacaoServicoCotacao { get; set; }
        public DbSet<SolicitacaoServicoCotacaoItem> SolicitacaoServicoCotacaoItem { get; set; }

        public DbSet<SolicitacaoServicoMedicao> SolicitacaoServicoMedicao { get; set; }
        
        public DbSet<SolicitacaoServicoMedicaoItem> SolicitacaoServicoMedicaoItem { get; set; }

        public DbSet<SolicitacaoServicoMedicaoUnica> SolicitacaoServicoMedicaoUnica { get; set; }

        public DbSet<SolicitacaoServicoHistorico> SolicitacaoServicoHistorico { get; set; }


        public DbSet<ItemConta> ItemConta { get; set; }
        public DbSet<SubItemConta> SubItemConta { get; set; }
        public DbSet<ContaContabil> ContaContabil { get; set; }
        public DbSet<SetorAprovacao> SetorAprovacao { get; set; }
        public DbSet<Contrato> Contrato { get; set; }

        public DbSet<Comprador> Comprador { get; set; }
        public DbSet<CompradorSolicitante> CompradorSolicitante { get; set; }

        public DbSet<ResponsavelFornecedor> ResponsavelFornecedor { get; set; }

        //     public DbSet<PedidoCompra> PedidoCompra { get; set; }
        //     public DbSet<NotaFiscalCompra> NotaFiscalCompra { get; set; }
        //     public DbSet<Transportadora> Transportadora { get; set; }


        //public DbSet<TipoVeiculo> TipoVeiculo { get; set; }
        //public DbSet<TipoProduto> TipoProduto { get; set; }
        //public DbSet<LocalEntrega> LocalEntrega { get; set; }
        //public DbSet<TempoDescarregamento> TempoDescarregamento { get; set; }
        //public DbSet<ExcecaoAgenda> ExcecaoAgenda { get; set; }
        //public DbSet<Motorista> Motorista { get; set; }

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
            builder.Entity<Empresa>().HasIndex(u => u.Client_Key).IsUnique();
            builder.Entity<Unidade>().HasIndex(u => u.CNPJ).IsUnique();
            builder.Entity<Banco>().HasIndex(u => u.Codigo).IsUnique();
            builder.Entity<Cedente>().HasIndex(u => new { u.CPFCNPJ, u.Codigo }).IsUnique();
            builder.Entity<Sacado>().HasIndex(u => new { u.EmpresaID, u.UnidadeID, u.CPFCNPJ }).IsUnique();


            builder.Entity<GrupoSacado>()
             .HasOne(r => r.Empresa)
             .WithOne();

        }

        #endregion SETUP
    }
}
