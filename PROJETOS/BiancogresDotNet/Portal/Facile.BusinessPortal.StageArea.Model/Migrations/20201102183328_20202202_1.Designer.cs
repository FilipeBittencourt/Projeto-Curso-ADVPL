﻿// <auto-generated />
using System;
using Facile.BusinessPortal.StageArea.Model;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Infrastructure;
using Microsoft.EntityFrameworkCore.Metadata;
using Microsoft.EntityFrameworkCore.Migrations;
using Microsoft.EntityFrameworkCore.Storage.ValueConversion;

namespace Facile.BusinessPortal.StageArea.Model.Migrations
{
    [DbContext(typeof(FBSAContext))]
    [Migration("20201102183328_20202202_1")]
    partial class _20202202_1
    {
        protected override void BuildTargetModel(ModelBuilder modelBuilder)
        {
#pragma warning disable 612, 618
            modelBuilder
                .HasAnnotation("ProductVersion", "2.2.6-servicing-10079")
                .HasAnnotation("Relational:MaxIdentifierLength", 128)
                .HasAnnotation("SqlServer:ValueGenerationStrategy", SqlServerValueGenerationStrategy.IdentityColumn);

            modelBuilder.Entity("Facile.BusinessPortal.StageArea.Model.Antecipacao", b =>
                {
                    b.Property<long>("ID")
                        .ValueGeneratedOnAdd()
                        .HasAnnotation("SqlServer:ValueGenerationStrategy", SqlServerValueGenerationStrategy.IdentityColumn);

                    b.Property<string>("ChaveUnica")
                        .IsRequired();

                    b.Property<string>("Contato");

                    b.Property<DateTime>("DataEmissao");

                    b.Property<DateTime?>("DataHoraIntegracao");

                    b.Property<DateTime>("DataRecebimento");

                    b.Property<long>("EmpresaID");

                    b.Property<string>("FornecedorCPFCNPJ");

                    b.Property<DateTime?>("InsertDate");

                    b.Property<string>("InsertUser");

                    b.Property<DateTime?>("LastEditDate");

                    b.Property<string>("LastEditUser");

                    b.Property<string>("MensagemRetorno");

                    b.Property<string>("Observacao");

                    b.Property<int>("Origem");

                    b.Property<int>("Status");

                    b.Property<int>("StatusIntegracao");

                    b.Property<decimal>("Taxa");

                    b.Property<long?>("UnidadeID");

                    b.HasKey("ID");

                    b.ToTable("Antecipacao");
                });

            modelBuilder.Entity("Facile.BusinessPortal.StageArea.Model.AntecipacaoItem", b =>
                {
                    b.Property<long>("ID")
                        .ValueGeneratedOnAdd()
                        .HasAnnotation("SqlServer:ValueGenerationStrategy", SqlServerValueGenerationStrategy.IdentityColumn);

                    b.Property<long>("AntecipacaoID");

                    b.Property<string>("ChaveUnica")
                        .IsRequired();

                    b.Property<DateTime?>("DataHoraIntegracao");

                    b.Property<long>("EmpresaID");

                    b.Property<DateTime?>("InsertDate");

                    b.Property<string>("InsertUser");

                    b.Property<DateTime?>("LastEditDate");

                    b.Property<string>("LastEditUser");

                    b.Property<string>("MensagemRetorno");

                    b.Property<string>("NumeroControleParticipante");

                    b.Property<string>("NumeroDocumento");

                    b.Property<string>("Parcela");

                    b.Property<string>("Serie");

                    b.Property<int>("StatusIntegracao");

                    b.Property<long>("TituloPagarID");

                    b.Property<long?>("UnidadeID");

                    b.Property<decimal>("ValorTitulo");

                    b.Property<decimal>("ValorTituloAntecipado");

                    b.HasKey("ID");

                    b.ToTable("AntecipacaoItem");
                });

            modelBuilder.Entity("Facile.BusinessPortal.StageArea.Model.Boleto", b =>
                {
                    b.Property<long>("ID")
                        .ValueGeneratedOnAdd()
                        .HasAnnotation("SqlServer:ValueGenerationStrategy", SqlServerValueGenerationStrategy.IdentityColumn);

                    b.Property<string>("Aceite");

                    b.Property<string>("Carteira");

                    b.Property<string>("Cedente_CPFCNPJ");

                    b.Property<string>("Cedente_Codigo");

                    b.Property<string>("ChaveUnica")
                        .IsRequired();

                    b.Property<string>("CodigoBanco");

                    b.Property<string>("CodigoInstrucao1");

                    b.Property<string>("CodigoInstrucao2");

                    b.Property<int?>("CodigoMoeda");

                    b.Property<int?>("CodigoProtesto");

                    b.Property<DateTime?>("DataDesconto");

                    b.Property<DateTime>("DataEmissao");

                    b.Property<DateTime?>("DataHoraIntegracao");

                    b.Property<DateTime?>("DataJuros");

                    b.Property<DateTime?>("DataMulta");

                    b.Property<DateTime?>("DataProcessamento");

                    b.Property<DateTime?>("DataRecebimento");

                    b.Property<DateTime>("DataVencimento");

                    b.Property<bool>("Deletado");

                    b.Property<int?>("DiasProtesto");

                    b.Property<long>("EmpresaID");

                    b.Property<string>("EnviarEmailCedente");

                    b.Property<string>("EnviarEmailSacado");

                    b.Property<int?>("EspecieDocumento");

                    b.Property<string>("EspecieMoeda");

                    b.Property<DateTime?>("InsertDate");

                    b.Property<string>("InsertUser");

                    b.Property<DateTime?>("LastEditDate");

                    b.Property<string>("LastEditUser");

                    b.Property<string>("MensagemArquivoRemessa");

                    b.Property<string>("MensagemLivreLinha1");

                    b.Property<string>("MensagemLivreLinha2");

                    b.Property<string>("MensagemLivreLinha3");

                    b.Property<string>("MensagemRetorno");

                    b.Property<string>("NossoNumero");

                    b.Property<string>("NumeroControleParticipante");

                    b.Property<string>("NumeroDocumento");

                    b.Property<string>("NumeroLote");

                    b.Property<decimal?>("PercentualJurosDia");

                    b.Property<decimal?>("PercentualMulta");

                    b.Property<string>("Reimpressao");

                    b.Property<string>("Sacado_CPFCNPJ");

                    b.Property<int>("StatusIntegracao");

                    b.Property<int?>("TipoCarteira");

                    b.Property<long?>("UnidadeID");

                    b.Property<decimal?>("ValorDesconto");

                    b.Property<decimal?>("ValorJurosDia");

                    b.Property<string>("ValorMoeda");

                    b.Property<decimal?>("ValorMulta");

                    b.Property<decimal?>("ValorOutrosAcrescimos");

                    b.Property<decimal>("ValorTitulo");

                    b.Property<string>("VariacaoCarteira");

                    b.HasKey("ID");

                    b.HasIndex("EmpresaID", "ChaveUnica")
                        .IsUnique();

                    b.ToTable("Boleto");
                });

            modelBuilder.Entity("Facile.BusinessPortal.StageArea.Model.EmpresaInterface", b =>
                {
                    b.Property<long>("ID")
                        .ValueGeneratedOnAdd()
                        .HasAnnotation("SqlServer:ValueGenerationStrategy", SqlServerValueGenerationStrategy.IdentityColumn);

                    b.Property<string>("CNPJ")
                        .IsRequired();

                    b.Property<string>("ChaveUnica")
                        .IsRequired();

                    b.Property<Guid>("Client_Key");

                    b.Property<string>("CodEmpresaERP");

                    b.Property<string>("CodUnidadeERP");

                    b.Property<string>("Codigo")
                        .IsRequired();

                    b.Property<DateTime?>("DataHoraIntegracao");

                    b.Property<long>("EmpresaID");

                    b.Property<DateTime?>("InsertDate");

                    b.Property<string>("InsertUser");

                    b.Property<DateTime?>("LastEditDate");

                    b.Property<string>("LastEditUser");

                    b.Property<string>("MensagemRetorno");

                    b.Property<string>("Secret_Key")
                        .IsRequired();

                    b.Property<int>("StatusIntegracao");

                    b.Property<long?>("UnidadeID");

                    b.HasKey("ID");

                    b.ToTable("EmpresaInterface");
                });

            modelBuilder.Entity("Facile.BusinessPortal.StageArea.Model.Fornecedor", b =>
                {
                    b.Property<long>("ID")
                        .ValueGeneratedOnAdd()
                        .HasAnnotation("SqlServer:ValueGenerationStrategy", SqlServerValueGenerationStrategy.IdentityColumn);

                    b.Property<string>("Bairro");

                    b.Property<string>("CEP");

                    b.Property<string>("CPFCNPJ");

                    b.Property<string>("ChaveUnica")
                        .IsRequired();

                    b.Property<string>("Cidade");

                    b.Property<string>("CodigoERP");

                    b.Property<string>("Complemento");

                    b.Property<bool>("CriarUsuario");

                    b.Property<DateTime?>("DataHoraIntegracao");

                    b.Property<string>("Email");

                    b.Property<string>("EmailWorkflow");

                    b.Property<long>("EmpresaID");

                    b.Property<bool>("Habilitado");

                    b.Property<DateTime?>("InsertDate");

                    b.Property<string>("InsertUser");

                    b.Property<DateTime?>("LastEditDate");

                    b.Property<string>("LastEditUser");

                    b.Property<string>("Logradouro");

                    b.Property<string>("MensagemRetorno");

                    b.Property<string>("Nome");

                    b.Property<string>("Numero");

                    b.Property<string>("Observacoes");

                    b.Property<decimal>("PercentualPorDia");

                    b.Property<int>("StatusIntegracao");

                    b.Property<int>("TipoAntecipacao");

                    b.Property<string>("UF");

                    b.Property<long?>("UnidadeID");

                    b.HasKey("ID");

                    b.HasIndex("EmpresaID", "ChaveUnica")
                        .IsUnique();

                    b.ToTable("Fornecedor");
                });

            modelBuilder.Entity("Facile.BusinessPortal.StageArea.Model.LogIntegracao", b =>
                {
                    b.Property<long>("ID")
                        .ValueGeneratedOnAdd()
                        .HasAnnotation("SqlServer:ValueGenerationStrategy", SqlServerValueGenerationStrategy.IdentityColumn);

                    b.Property<string>("ChaveUnica")
                        .IsRequired();

                    b.Property<DateTime?>("DataHoraIntegracao");

                    b.Property<long>("EmpresaID");

                    b.Property<long>("EntidadeID");

                    b.Property<string>("EntidadeNome");

                    b.Property<DateTime?>("InsertDate");

                    b.Property<string>("InsertUser");

                    b.Property<DateTime?>("LastEditDate");

                    b.Property<string>("LastEditUser");

                    b.Property<string>("MensagemRetorno");

                    b.Property<int>("StatusIntegracao");

                    b.Property<long?>("UnidadeID");

                    b.HasKey("ID");

                    b.ToTable("LogIntegracao");
                });

            modelBuilder.Entity("Facile.BusinessPortal.StageArea.Model.NotaFiscalCompra", b =>
                {
                    b.Property<long>("ID")
                        .ValueGeneratedOnAdd()
                        .HasAnnotation("SqlServer:ValueGenerationStrategy", SqlServerValueGenerationStrategy.IdentityColumn);

                    b.Property<string>("ChaveNFE");

                    b.Property<string>("ChaveUnica")
                        .IsRequired();

                    b.Property<DateTime>("DataEmissao");

                    b.Property<DateTime?>("DataHoraIntegracao");

                    b.Property<bool>("Deletado");

                    b.Property<long>("EmpresaID");

                    b.Property<string>("FornecedorCPFCNPJ");

                    b.Property<string>("FornecedorCodigoERP");

                    b.Property<string>("FornecedorLoja");

                    b.Property<DateTime?>("InsertDate");

                    b.Property<string>("InsertUser");

                    b.Property<DateTime?>("LastEditDate");

                    b.Property<string>("LastEditUser");

                    b.Property<string>("MensagemRetorno");

                    b.Property<string>("Numero");

                    b.Property<string>("NumeroControleParticipante");

                    b.Property<string>("PedidoItem");

                    b.Property<string>("PedidoNumero");

                    b.Property<string>("ProdutoCodigo");

                    b.Property<string>("ProdutoItem");

                    b.Property<string>("ProdutoNome");

                    b.Property<string>("ProdutoUnidade");

                    b.Property<decimal>("Quantidade");

                    b.Property<string>("Serie");

                    b.Property<int>("StatusIntegracao");

                    b.Property<string>("TransportadoraCPFCNPJ");

                    b.Property<long?>("UnidadeID");

                    b.Property<decimal>("Valor");

                    b.HasKey("ID");

                    b.ToTable("NotaFiscalCompra");
                });

            modelBuilder.Entity("Facile.BusinessPortal.StageArea.Model.PedidoCompra", b =>
                {
                    b.Property<long>("ID")
                        .ValueGeneratedOnAdd()
                        .HasAnnotation("SqlServer:ValueGenerationStrategy", SqlServerValueGenerationStrategy.IdentityColumn);

                    b.Property<string>("ChaveUnica")
                        .IsRequired();

                    b.Property<DateTime?>("DataEntrega");

                    b.Property<DateTime?>("DataHoraIntegracao");

                    b.Property<bool>("Deletado");

                    b.Property<long>("EmpresaID");

                    b.Property<string>("FornecedorCPFCNPJ");

                    b.Property<string>("FornecedorCodigoERP");

                    b.Property<string>("FornecedorLoja");

                    b.Property<DateTime?>("InsertDate");

                    b.Property<string>("InsertUser");

                    b.Property<DateTime?>("LastEditDate");

                    b.Property<string>("LastEditUser");

                    b.Property<string>("MensagemRetorno");

                    b.Property<string>("NumeroControleParticipante");

                    b.Property<string>("Pedido");

                    b.Property<string>("PedidoItem");

                    b.Property<string>("ProdutoCodigo");

                    b.Property<string>("ProdutoNome");

                    b.Property<string>("ProdutoUnidade");

                    b.Property<decimal>("Quantidade");

                    b.Property<decimal>("Saldo");

                    b.Property<int>("StatusIntegracao");

                    b.Property<int>("TipoFrete");

                    b.Property<string>("TransportadoraCPFCNPJ");

                    b.Property<long?>("UnidadeID");

                    b.HasKey("ID");

                    b.ToTable("PedidoCompra");
                });

            modelBuilder.Entity("Facile.BusinessPortal.StageArea.Model.ProcessoEmpresa", b =>
                {
                    b.Property<long>("ID")
                        .ValueGeneratedOnAdd()
                        .HasAnnotation("SqlServer:ValueGenerationStrategy", SqlServerValueGenerationStrategy.IdentityColumn);

                    b.Property<string>("ChaveUnica")
                        .IsRequired();

                    b.Property<DateTime?>("DataHoraIntegracao");

                    b.Property<long>("EmpresaID");

                    b.Property<long>("EmpresaInterfaceID");

                    b.Property<bool>("Habilitado");

                    b.Property<DateTime?>("InsertDate");

                    b.Property<string>("InsertUser");

                    b.Property<long?>("Interval");

                    b.Property<DateTime?>("LastEditDate");

                    b.Property<string>("LastEditUser");

                    b.Property<string>("MensagemRetorno");

                    b.Property<int>("ProcessoIntegracao");

                    b.Property<int>("StatusIntegracao");

                    b.Property<long?>("UnidadeID");

                    b.HasKey("ID");

                    b.HasIndex("EmpresaInterfaceID");

                    b.ToTable("ProcessoEmpresa");
                });

            modelBuilder.Entity("Facile.BusinessPortal.StageArea.Model.RPV", b =>
                {
                    b.Property<long>("ID")
                        .ValueGeneratedOnAdd()
                        .HasAnnotation("SqlServer:ValueGenerationStrategy", SqlServerValueGenerationStrategy.IdentityColumn);

                    b.Property<string>("ChaveUnica")
                        .IsRequired();

                    b.Property<string>("CodigoProduto");

                    b.Property<string>("Contato");

                    b.Property<DateTime?>("DataHoraIntegracao");

                    b.Property<DateTime>("DataLiberacao");

                    b.Property<bool>("Deletado");

                    b.Property<string>("Email");

                    b.Property<long>("EmpresaID");

                    b.Property<string>("FornecedorCPFCNPJ");

                    b.Property<DateTime?>("InsertDate");

                    b.Property<string>("InsertUser");

                    b.Property<string>("Item");

                    b.Property<DateTime?>("LastEditDate");

                    b.Property<string>("LastEditUser");

                    b.Property<string>("MensagemRetorno");

                    b.Property<string>("NomeProduto");

                    b.Property<string>("Numero");

                    b.Property<string>("NumeroContrato");

                    b.Property<string>("NumeroControleParticipante");

                    b.Property<string>("Observacao");

                    b.Property<decimal>("QuantidadeProduto");

                    b.Property<bool>("Status");

                    b.Property<int>("StatusIntegracao");

                    b.Property<long?>("UnidadeID");

                    b.HasKey("ID");

                    b.ToTable("RPV");
                });

            modelBuilder.Entity("Facile.BusinessPortal.StageArea.Model.Sacado", b =>
                {
                    b.Property<long>("ID")
                        .ValueGeneratedOnAdd()
                        .HasAnnotation("SqlServer:ValueGenerationStrategy", SqlServerValueGenerationStrategy.IdentityColumn);

                    b.Property<string>("Bairro");

                    b.Property<string>("CEP");

                    b.Property<string>("CPFCNPJ");

                    b.Property<string>("ChaveUnica")
                        .IsRequired();

                    b.Property<string>("Cidade");

                    b.Property<string>("CodigoERP");

                    b.Property<string>("Complemento");

                    b.Property<bool>("CriarUsuario");

                    b.Property<DateTime?>("DataHoraIntegracao");

                    b.Property<string>("EmailUsuario");

                    b.Property<string>("EmailWorkflow");

                    b.Property<long>("EmpresaID");

                    b.Property<string>("GrupoSacado");

                    b.Property<bool>("Habilitado");

                    b.Property<DateTime?>("InsertDate");

                    b.Property<string>("InsertUser");

                    b.Property<DateTime?>("LastEditDate");

                    b.Property<string>("LastEditUser");

                    b.Property<string>("Logradouro");

                    b.Property<string>("MensagemRetorno");

                    b.Property<string>("Nome");

                    b.Property<string>("Numero");

                    b.Property<string>("Observacoes");

                    b.Property<int>("StatusIntegracao");

                    b.Property<string>("UF");

                    b.Property<long?>("UnidadeID");

                    b.HasKey("ID");

                    b.HasIndex("EmpresaID", "ChaveUnica")
                        .IsUnique();

                    b.HasIndex("EmpresaID", "UnidadeID", "CPFCNPJ")
                        .IsUnique()
                        .HasFilter("[UnidadeID] IS NOT NULL AND [CPFCNPJ] IS NOT NULL");

                    b.ToTable("Sacado");
                });

            modelBuilder.Entity("Facile.BusinessPortal.StageArea.Model.TaxaAntecipacao", b =>
                {
                    b.Property<long>("ID")
                        .ValueGeneratedOnAdd()
                        .HasAnnotation("SqlServer:ValueGenerationStrategy", SqlServerValueGenerationStrategy.IdentityColumn);

                    b.Property<string>("ChaveUnica")
                        .IsRequired();

                    b.Property<string>("CodigoERP");

                    b.Property<DateTime?>("DataHoraIntegracao");

                    b.Property<long>("EmpresaID");

                    b.Property<string>("FornecedorCPFCNPJ");

                    b.Property<DateTime?>("InsertDate");

                    b.Property<string>("InsertUser");

                    b.Property<DateTime?>("LastEditDate");

                    b.Property<string>("LastEditUser");

                    b.Property<string>("MensagemRetorno");

                    b.Property<int>("StatusIntegracao");

                    b.Property<decimal>("Taxa");

                    b.Property<long?>("UnidadeID");

                    b.HasKey("ID");

                    b.ToTable("TaxaAntecipacao");
                });

            modelBuilder.Entity("Facile.BusinessPortal.StageArea.Model.TituloPagar", b =>
                {
                    b.Property<long>("ID")
                        .ValueGeneratedOnAdd()
                        .HasAnnotation("SqlServer:ValueGenerationStrategy", SqlServerValueGenerationStrategy.IdentityColumn);

                    b.Property<string>("ChaveUnica")
                        .IsRequired();

                    b.Property<DateTime?>("DataBaixa");

                    b.Property<DateTime>("DataEmissao");

                    b.Property<DateTime?>("DataHoraIntegracao");

                    b.Property<DateTime?>("DataPagamento");

                    b.Property<DateTime>("DataVencimento");

                    b.Property<bool>("Deletado");

                    b.Property<long>("EmpresaID");

                    b.Property<string>("FormaPagamento");

                    b.Property<string>("FornecedorCPFCNPJ");

                    b.Property<DateTime?>("InsertDate");

                    b.Property<string>("InsertUser");

                    b.Property<DateTime?>("LastEditDate");

                    b.Property<string>("LastEditUser");

                    b.Property<string>("MensagemRetorno");

                    b.Property<string>("NumeroControleParticipante");

                    b.Property<string>("NumeroDocumento");

                    b.Property<string>("Parcela");

                    b.Property<decimal>("Saldo");

                    b.Property<string>("Serie");

                    b.Property<int>("StatusIntegracao");

                    b.Property<long?>("UnidadeID");

                    b.Property<decimal>("ValorTitulo");

                    b.HasKey("ID");

                    b.HasIndex("EmpresaID", "ChaveUnica", "Deletado")
                        .IsUnique();

                    b.ToTable("TituloPagar");
                });

            modelBuilder.Entity("Facile.BusinessPortal.StageArea.Model.Transportadora", b =>
                {
                    b.Property<long>("ID")
                        .ValueGeneratedOnAdd()
                        .HasAnnotation("SqlServer:ValueGenerationStrategy", SqlServerValueGenerationStrategy.IdentityColumn);

                    b.Property<string>("Bairro");

                    b.Property<string>("CEP");

                    b.Property<string>("CPFCNPJ");

                    b.Property<string>("ChaveUnica")
                        .IsRequired();

                    b.Property<string>("Cidade");

                    b.Property<string>("CodigoERP");

                    b.Property<string>("Complemento");

                    b.Property<bool>("CriarUsuario");

                    b.Property<DateTime?>("DataHoraIntegracao");

                    b.Property<string>("Email");

                    b.Property<long>("EmpresaID");

                    b.Property<bool>("Habilitado");

                    b.Property<DateTime?>("InsertDate");

                    b.Property<string>("InsertUser");

                    b.Property<DateTime?>("LastEditDate");

                    b.Property<string>("LastEditUser");

                    b.Property<string>("Logradouro");

                    b.Property<string>("MensagemRetorno");

                    b.Property<string>("Nome");

                    b.Property<string>("Numero");

                    b.Property<string>("Observacoes");

                    b.Property<int>("StatusIntegracao");

                    b.Property<string>("UF");

                    b.Property<long?>("UnidadeID");

                    b.HasKey("ID");

                    b.ToTable("Transportadora");
                });

            modelBuilder.Entity("Facile.BusinessPortal.StageArea.Model.ProcessoEmpresa", b =>
                {
                    b.HasOne("Facile.BusinessPortal.StageArea.Model.EmpresaInterface", "EmpresaInterface")
                        .WithMany()
                        .HasForeignKey("EmpresaInterfaceID")
                        .OnDelete(DeleteBehavior.Restrict);
                });
#pragma warning restore 612, 618
        }
    }
}
