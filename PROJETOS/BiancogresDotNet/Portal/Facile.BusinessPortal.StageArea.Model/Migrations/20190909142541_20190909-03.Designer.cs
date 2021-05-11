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
    [Migration("20190909142541_20190909-03")]
    partial class _2019090903
    {
        protected override void BuildTargetModel(ModelBuilder modelBuilder)
        {
#pragma warning disable 612, 618
            modelBuilder
                .HasAnnotation("ProductVersion", "2.2.6-servicing-10079")
                .HasAnnotation("Relational:MaxIdentifierLength", 128)
                .HasAnnotation("SqlServer:ValueGenerationStrategy", SqlServerValueGenerationStrategy.IdentityColumn);

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

                    b.Property<DateTime?>("DataCredito");

                    b.Property<DateTime?>("DataDesconto");

                    b.Property<DateTime>("DataEmissao");

                    b.Property<DateTime?>("DataHoraIntegracao");

                    b.Property<DateTime?>("DataJuros");

                    b.Property<DateTime?>("DataMulta");

                    b.Property<DateTime?>("DataProcessamento");

                    b.Property<DateTime>("DataVencimento");

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

                    b.Property<long>("UnidadeID");

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

                    b.Property<long>("UnidadeID");

                    b.HasKey("ID");

                    b.ToTable("LogIntegracao");
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

                    b.Property<string>("Complemento");

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

                    b.Property<long>("UnidadeID");

                    b.HasKey("ID");

                    b.HasIndex("EmpresaID", "ChaveUnica")
                        .IsUnique();

                    b.HasIndex("EmpresaID", "UnidadeID", "CPFCNPJ")
                        .IsUnique()
                        .HasFilter("[CPFCNPJ] IS NOT NULL");

                    b.ToTable("Sacado");
                });
#pragma warning restore 612, 618
        }
    }
}
