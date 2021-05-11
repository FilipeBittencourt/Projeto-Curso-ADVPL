using System;
using Microsoft.EntityFrameworkCore.Metadata;
using Microsoft.EntityFrameworkCore.Migrations;

namespace Facile.BusinessPortal.Model.Migrations
{
    public partial class initial01 : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_AspNetRoleClaims_AspNetRoles_RoleId",
                table: "AspNetRoleClaims");

            migrationBuilder.DropForeignKey(
                name: "FK_AspNetUserClaims_AspNetUsers_UserId",
                table: "AspNetUserClaims");

            migrationBuilder.DropForeignKey(
                name: "FK_AspNetUserLogins_AspNetUsers_UserId",
                table: "AspNetUserLogins");

            migrationBuilder.DropForeignKey(
                name: "FK_AspNetUserRoles_AspNetRoles_RoleId",
                table: "AspNetUserRoles");

            migrationBuilder.DropForeignKey(
                name: "FK_AspNetUserRoles_AspNetUsers_UserId",
                table: "AspNetUserRoles");

            migrationBuilder.DropForeignKey(
                name: "FK_AspNetUserTokens_AspNetUsers_UserId",
                table: "AspNetUserTokens");

            migrationBuilder.CreateTable(
                name: "Banco",
                columns: table => new
                {
                    ID = table.Column<long>(nullable: false)
                        .Annotation("SqlServer:ValueGenerationStrategy", SqlServerValueGenerationStrategy.IdentityColumn),
                    InsertUser = table.Column<string>(nullable: true),
                    InsertDate = table.Column<DateTime>(nullable: true),
                    LastEditUser = table.Column<string>(nullable: true),
                    LastEditDate = table.Column<DateTime>(nullable: true),
                    Codigo = table.Column<string>(nullable: true),
                    Nome = table.Column<string>(nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Banco", x => x.ID);
                });

            migrationBuilder.CreateTable(
                name: "Empresa",
                columns: table => new
                {
                    ID = table.Column<long>(nullable: false)
                        .Annotation("SqlServer:ValueGenerationStrategy", SqlServerValueGenerationStrategy.IdentityColumn),
                    InsertUser = table.Column<string>(nullable: true),
                    InsertDate = table.Column<DateTime>(nullable: true),
                    LastEditUser = table.Column<string>(nullable: true),
                    LastEditDate = table.Column<DateTime>(nullable: true),
                    Codigo = table.Column<string>(maxLength: 10, nullable: false),
                    Client_Key = table.Column<Guid>(nullable: false),
                    NomeEmpresa = table.Column<string>(nullable: false),
                    DiretorioBaseArquivo = table.Column<string>(nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Empresa", x => x.ID);
                });

            migrationBuilder.CreateTable(
                name: "LogApi",
                columns: table => new
                {
                    ID = table.Column<long>(nullable: false)
                        .Annotation("SqlServer:ValueGenerationStrategy", SqlServerValueGenerationStrategy.IdentityColumn),
                    InsertUser = table.Column<string>(nullable: true),
                    InsertDate = table.Column<DateTime>(nullable: true),
                    LastEditUser = table.Column<string>(nullable: true),
                    LastEditDate = table.Column<DateTime>(nullable: true),
                    EmpresaID = table.Column<long>(nullable: true),
                    UnidadeID = table.Column<long>(nullable: true),
                    Usuario = table.Column<string>(nullable: true),
                    Controller = table.Column<string>(nullable: true),
                    Action = table.Column<string>(nullable: true),
                    RequestIP = table.Column<string>(nullable: true),
                    RequestMethod = table.Column<string>(nullable: true),
                    RequestUrl = table.Column<string>(nullable: true),
                    MensagemRetornoErro = table.Column<string>(nullable: true),
                    CedenteID = table.Column<long>(nullable: true),
                    BoletoID = table.Column<long>(nullable: true),
                    NossoNumero = table.Column<string>(nullable: true),
                    IDProcesso = table.Column<Guid>(nullable: true),
                    RequestBody = table.Column<byte[]>(nullable: true),
                    ResponseBody = table.Column<byte[]>(nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_LogApi", x => x.ID);
                });

            migrationBuilder.CreateTable(
                name: "LogApiHistorico",
                columns: table => new
                {
                    ID = table.Column<long>(nullable: false)
                        .Annotation("SqlServer:ValueGenerationStrategy", SqlServerValueGenerationStrategy.IdentityColumn),
                    InsertUser = table.Column<string>(nullable: true),
                    InsertDate = table.Column<DateTime>(nullable: true),
                    LastEditUser = table.Column<string>(nullable: true),
                    LastEditDate = table.Column<DateTime>(nullable: true),
                    EmpresaID = table.Column<long>(nullable: true),
                    UnidadeID = table.Column<long>(nullable: true),
                    Usuario = table.Column<string>(nullable: true),
                    Controller = table.Column<string>(nullable: true),
                    Action = table.Column<string>(nullable: true),
                    RequestIP = table.Column<string>(nullable: true),
                    RequestMethod = table.Column<string>(nullable: true),
                    RequestBodyOld = table.Column<string>(nullable: true),
                    RequestUrl = table.Column<string>(nullable: true),
                    ResponseBodyOld = table.Column<string>(nullable: true),
                    CedenteID = table.Column<long>(nullable: true),
                    BoletoID = table.Column<long>(nullable: true),
                    NossoNumero = table.Column<string>(nullable: true),
                    IDProcesso = table.Column<Guid>(nullable: true),
                    RequestBody = table.Column<byte[]>(nullable: true),
                    ResponseBody = table.Column<byte[]>(nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_LogApiHistorico", x => x.ID);
                });

            migrationBuilder.CreateTable(
                name: "Unidade",
                columns: table => new
                {
                    ID = table.Column<long>(nullable: false)
                        .Annotation("SqlServer:ValueGenerationStrategy", SqlServerValueGenerationStrategy.IdentityColumn),
                    InsertUser = table.Column<string>(nullable: true),
                    InsertDate = table.Column<DateTime>(nullable: true),
                    LastEditUser = table.Column<string>(nullable: true),
                    LastEditDate = table.Column<DateTime>(nullable: true),
                    EmpresaID = table.Column<long>(nullable: false),
                    UnidadeID = table.Column<long>(nullable: true),
                    Habilitado = table.Column<bool>(nullable: false),
                    Deletado = table.Column<bool>(nullable: false),
                    DeleteID = table.Column<long>(nullable: false),
                    IDProcesso = table.Column<Guid>(nullable: true),
                    CNPJ = table.Column<string>(maxLength: 14, nullable: false),
                    Codigo = table.Column<string>(nullable: false),
                    Nome = table.Column<string>(nullable: false),
                    Apelido = table.Column<string>(nullable: true),
                    Secret_Key = table.Column<string>(nullable: true),
                    DiretorioBaseArquivo = table.Column<string>(nullable: true),
                    SalvaBoletoPdf = table.Column<bool>(nullable: false),
                    CaminhoDestinoBoletos = table.Column<string>(nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Unidade", x => x.ID);
                    table.ForeignKey(
                        name: "FK_Unidade_Empresa_EmpresaID",
                        column: x => x.EmpresaID,
                        principalTable: "Empresa",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_Unidade_Unidade_UnidadeID",
                        column: x => x.UnidadeID,
                        principalTable: "Unidade",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "Acao",
                columns: table => new
                {
                    ID = table.Column<long>(nullable: false)
                        .Annotation("SqlServer:ValueGenerationStrategy", SqlServerValueGenerationStrategy.IdentityColumn),
                    InsertUser = table.Column<string>(nullable: true),
                    InsertDate = table.Column<DateTime>(nullable: true),
                    LastEditUser = table.Column<string>(nullable: true),
                    LastEditDate = table.Column<DateTime>(nullable: true),
                    EmpresaID = table.Column<long>(nullable: false),
                    UnidadeID = table.Column<long>(nullable: true),
                    Habilitado = table.Column<bool>(nullable: false),
                    Deletado = table.Column<bool>(nullable: false),
                    DeleteID = table.Column<long>(nullable: false),
                    IDProcesso = table.Column<Guid>(nullable: true),
                    Nome = table.Column<string>(nullable: false),
                    Codigo = table.Column<string>(nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Acao", x => x.ID);
                    table.ForeignKey(
                        name: "FK_Acao_Empresa_EmpresaID",
                        column: x => x.EmpresaID,
                        principalTable: "Empresa",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_Acao_Unidade_UnidadeID",
                        column: x => x.UnidadeID,
                        principalTable: "Unidade",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "ContaBancaria",
                columns: table => new
                {
                    ID = table.Column<long>(nullable: false)
                        .Annotation("SqlServer:ValueGenerationStrategy", SqlServerValueGenerationStrategy.IdentityColumn),
                    InsertUser = table.Column<string>(nullable: true),
                    InsertDate = table.Column<DateTime>(nullable: true),
                    LastEditUser = table.Column<string>(nullable: true),
                    LastEditDate = table.Column<DateTime>(nullable: true),
                    EmpresaID = table.Column<long>(nullable: false),
                    UnidadeID = table.Column<long>(nullable: true),
                    Habilitado = table.Column<bool>(nullable: false),
                    Deletado = table.Column<bool>(nullable: false),
                    DeleteID = table.Column<long>(nullable: false),
                    IDProcesso = table.Column<Guid>(nullable: true),
                    BancoID = table.Column<long>(nullable: false),
                    Agencia = table.Column<string>(nullable: false),
                    DigitoAgencia = table.Column<string>(nullable: true),
                    Conta = table.Column<string>(nullable: false),
                    DigitoConta = table.Column<string>(nullable: false),
                    CarteiraPadrao = table.Column<string>(nullable: true),
                    VariacaoCarteiraPadrao = table.Column<string>(nullable: true),
                    TipoCarteiraPadrao = table.Column<int>(nullable: true),
                    TipoFormaCadastramento = table.Column<int>(nullable: true),
                    TipoImpressaoBoleto = table.Column<int>(nullable: true),
                    EspecieDocumento = table.Column<int>(nullable: true),
                    AceitePadrao = table.Column<string>(nullable: true),
                    EspecieMoeda = table.Column<string>(nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ContaBancaria", x => x.ID);
                    table.ForeignKey(
                        name: "FK_ContaBancaria_Banco_BancoID",
                        column: x => x.BancoID,
                        principalTable: "Banco",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_ContaBancaria_Empresa_EmpresaID",
                        column: x => x.EmpresaID,
                        principalTable: "Empresa",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_ContaBancaria_Unidade_UnidadeID",
                        column: x => x.UnidadeID,
                        principalTable: "Unidade",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "Fornecedor",
                columns: table => new
                {
                    ID = table.Column<long>(nullable: false)
                        .Annotation("SqlServer:ValueGenerationStrategy", SqlServerValueGenerationStrategy.IdentityColumn),
                    InsertUser = table.Column<string>(nullable: true),
                    InsertDate = table.Column<DateTime>(nullable: true),
                    LastEditUser = table.Column<string>(nullable: true),
                    LastEditDate = table.Column<DateTime>(nullable: true),
                    EmpresaID = table.Column<long>(nullable: false),
                    UnidadeID = table.Column<long>(nullable: true),
                    Habilitado = table.Column<bool>(nullable: false),
                    Deletado = table.Column<bool>(nullable: false),
                    DeleteID = table.Column<long>(nullable: false),
                    IDProcesso = table.Column<Guid>(nullable: true),
                    CPFCNPJ = table.Column<string>(nullable: false),
                    Nome = table.Column<string>(nullable: false),
                    Email = table.Column<string>(nullable: true),
                    Observacoes = table.Column<string>(nullable: true),
                    CEP = table.Column<string>(nullable: false),
                    Logradouro = table.Column<string>(nullable: false),
                    Bairro = table.Column<string>(nullable: true),
                    UF = table.Column<string>(nullable: false),
                    Cidade = table.Column<string>(nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Fornecedor", x => x.ID);
                    table.ForeignKey(
                        name: "FK_Fornecedor_Empresa_EmpresaID",
                        column: x => x.EmpresaID,
                        principalTable: "Empresa",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_Fornecedor_Unidade_UnidadeID",
                        column: x => x.UnidadeID,
                        principalTable: "Unidade",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "GrupoSacado",
                columns: table => new
                {
                    ID = table.Column<long>(nullable: false)
                        .Annotation("SqlServer:ValueGenerationStrategy", SqlServerValueGenerationStrategy.IdentityColumn),
                    InsertUser = table.Column<string>(nullable: true),
                    InsertDate = table.Column<DateTime>(nullable: true),
                    LastEditUser = table.Column<string>(nullable: true),
                    LastEditDate = table.Column<DateTime>(nullable: true),
                    EmpresaID = table.Column<long>(nullable: false),
                    UnidadeID = table.Column<long>(nullable: true),
                    Habilitado = table.Column<bool>(nullable: false),
                    Deletado = table.Column<bool>(nullable: false),
                    DeleteID = table.Column<long>(nullable: false),
                    IDProcesso = table.Column<Guid>(nullable: true),
                    CodigoUnico = table.Column<string>(nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_GrupoSacado", x => x.ID);
                    table.ForeignKey(
                        name: "FK_GrupoSacado_Empresa_EmpresaID",
                        column: x => x.EmpresaID,
                        principalTable: "Empresa",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_GrupoSacado_Unidade_UnidadeID",
                        column: x => x.UnidadeID,
                        principalTable: "Unidade",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "GrupoUsuario",
                columns: table => new
                {
                    ID = table.Column<long>(nullable: false)
                        .Annotation("SqlServer:ValueGenerationStrategy", SqlServerValueGenerationStrategy.IdentityColumn),
                    InsertUser = table.Column<string>(nullable: true),
                    InsertDate = table.Column<DateTime>(nullable: true),
                    LastEditUser = table.Column<string>(nullable: true),
                    LastEditDate = table.Column<DateTime>(nullable: true),
                    EmpresaID = table.Column<long>(nullable: false),
                    UnidadeID = table.Column<long>(nullable: true),
                    Habilitado = table.Column<bool>(nullable: false),
                    Deletado = table.Column<bool>(nullable: false),
                    DeleteID = table.Column<long>(nullable: false),
                    IDProcesso = table.Column<Guid>(nullable: true),
                    Nome = table.Column<string>(nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_GrupoUsuario", x => x.ID);
                    table.ForeignKey(
                        name: "FK_GrupoUsuario_Empresa_EmpresaID",
                        column: x => x.EmpresaID,
                        principalTable: "Empresa",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_GrupoUsuario_Unidade_UnidadeID",
                        column: x => x.UnidadeID,
                        principalTable: "Unidade",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "Lote",
                columns: table => new
                {
                    ID = table.Column<long>(nullable: false)
                        .Annotation("SqlServer:ValueGenerationStrategy", SqlServerValueGenerationStrategy.IdentityColumn),
                    InsertUser = table.Column<string>(nullable: true),
                    InsertDate = table.Column<DateTime>(nullable: true),
                    LastEditUser = table.Column<string>(nullable: true),
                    LastEditDate = table.Column<DateTime>(nullable: true),
                    EmpresaID = table.Column<long>(nullable: false),
                    UnidadeID = table.Column<long>(nullable: true),
                    Habilitado = table.Column<bool>(nullable: false),
                    Deletado = table.Column<bool>(nullable: false),
                    DeleteID = table.Column<long>(nullable: false),
                    IDProcesso = table.Column<Guid>(nullable: true),
                    Numero = table.Column<string>(nullable: false),
                    NomeArquivo = table.Column<string>(nullable: true),
                    GerarArquivoRemessa = table.Column<bool>(nullable: false),
                    ProcessaRetornoAutomatico = table.Column<bool>(nullable: false),
                    Parcial = table.Column<bool>(nullable: false),
                    TipoArquivo = table.Column<int>(nullable: false),
                    Operacao = table.Column<int>(nullable: false),
                    NumeroSequencialRemessa = table.Column<int>(nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Lote", x => x.ID);
                    table.ForeignKey(
                        name: "FK_Lote_Empresa_EmpresaID",
                        column: x => x.EmpresaID,
                        principalTable: "Empresa",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_Lote_Unidade_UnidadeID",
                        column: x => x.UnidadeID,
                        principalTable: "Unidade",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "Mail",
                columns: table => new
                {
                    ID = table.Column<long>(nullable: false)
                        .Annotation("SqlServer:ValueGenerationStrategy", SqlServerValueGenerationStrategy.IdentityColumn),
                    InsertUser = table.Column<string>(nullable: true),
                    InsertDate = table.Column<DateTime>(nullable: true),
                    LastEditUser = table.Column<string>(nullable: true),
                    LastEditDate = table.Column<DateTime>(nullable: true),
                    EmpresaID = table.Column<long>(nullable: false),
                    UnidadeID = table.Column<long>(nullable: true),
                    Habilitado = table.Column<bool>(nullable: false),
                    Deletado = table.Column<bool>(nullable: false),
                    DeleteID = table.Column<long>(nullable: false),
                    IDProcesso = table.Column<Guid>(nullable: true),
                    Host = table.Column<string>(nullable: true),
                    Port = table.Column<int>(nullable: false),
                    User = table.Column<string>(nullable: true),
                    Password = table.Column<string>(nullable: true),
                    SSL = table.Column<bool>(nullable: false),
                    SenderEmail = table.Column<string>(nullable: true),
                    SenderDisplayName = table.Column<string>(nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Mail", x => x.ID);
                    table.ForeignKey(
                        name: "FK_Mail_Empresa_EmpresaID",
                        column: x => x.EmpresaID,
                        principalTable: "Empresa",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_Mail_Unidade_UnidadeID",
                        column: x => x.UnidadeID,
                        principalTable: "Unidade",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "Modulo",
                columns: table => new
                {
                    ID = table.Column<long>(nullable: false)
                        .Annotation("SqlServer:ValueGenerationStrategy", SqlServerValueGenerationStrategy.IdentityColumn),
                    InsertUser = table.Column<string>(nullable: true),
                    InsertDate = table.Column<DateTime>(nullable: true),
                    LastEditUser = table.Column<string>(nullable: true),
                    LastEditDate = table.Column<DateTime>(nullable: true),
                    EmpresaID = table.Column<long>(nullable: false),
                    UnidadeID = table.Column<long>(nullable: true),
                    Habilitado = table.Column<bool>(nullable: false),
                    Deletado = table.Column<bool>(nullable: false),
                    DeleteID = table.Column<long>(nullable: false),
                    IDProcesso = table.Column<Guid>(nullable: true),
                    Nome = table.Column<string>(nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Modulo", x => x.ID);
                    table.ForeignKey(
                        name: "FK_Modulo_Empresa_EmpresaID",
                        column: x => x.EmpresaID,
                        principalTable: "Empresa",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_Modulo_Unidade_UnidadeID",
                        column: x => x.UnidadeID,
                        principalTable: "Unidade",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "Cedente",
                columns: table => new
                {
                    ID = table.Column<long>(nullable: false)
                        .Annotation("SqlServer:ValueGenerationStrategy", SqlServerValueGenerationStrategy.IdentityColumn),
                    InsertUser = table.Column<string>(nullable: true),
                    InsertDate = table.Column<DateTime>(nullable: true),
                    LastEditUser = table.Column<string>(nullable: true),
                    LastEditDate = table.Column<DateTime>(nullable: true),
                    EmpresaID = table.Column<long>(nullable: false),
                    UnidadeID = table.Column<long>(nullable: true),
                    Habilitado = table.Column<bool>(nullable: false),
                    Deletado = table.Column<bool>(nullable: false),
                    DeleteID = table.Column<long>(nullable: false),
                    IDProcesso = table.Column<Guid>(nullable: true),
                    CPFCNPJ = table.Column<string>(nullable: false),
                    Nome = table.Column<string>(nullable: false),
                    Codigo = table.Column<string>(nullable: false),
                    CodigoDV = table.Column<string>(nullable: true),
                    CodigoCedenteBanco = table.Column<string>(nullable: true),
                    IdUnicoCedenteBancoRetorno = table.Column<string>(nullable: true),
                    Email = table.Column<string>(nullable: true),
                    ContaBancariaID = table.Column<long>(nullable: false),
                    NomeBasePdfBoleto = table.Column<string>(nullable: true),
                    Homologacao = table.Column<bool>(nullable: false),
                    DownloadRetorno = table.Column<bool>(nullable: false),
                    DownloadRetornoPagamento = table.Column<bool>(nullable: false),
                    EmailHomologacao = table.Column<string>(nullable: true),
                    RegiaoCobrancaEmail = table.Column<string>(nullable: true),
                    TelCobrancaEmail = table.Column<string>(nullable: true),
                    TelCobrancaExtEmail = table.Column<string>(nullable: true),
                    CEP = table.Column<string>(nullable: false),
                    Logradouro = table.Column<string>(nullable: false),
                    Bairro = table.Column<string>(nullable: true),
                    UF = table.Column<string>(nullable: false),
                    Cidade = table.Column<string>(nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Cedente", x => x.ID);
                    table.ForeignKey(
                        name: "FK_Cedente_ContaBancaria_ContaBancariaID",
                        column: x => x.ContaBancariaID,
                        principalTable: "ContaBancaria",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_Cedente_Empresa_EmpresaID",
                        column: x => x.EmpresaID,
                        principalTable: "Empresa",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_Cedente_Unidade_UnidadeID",
                        column: x => x.UnidadeID,
                        principalTable: "Unidade",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "Antecipacao",
                columns: table => new
                {
                    ID = table.Column<long>(nullable: false)
                        .Annotation("SqlServer:ValueGenerationStrategy", SqlServerValueGenerationStrategy.IdentityColumn),
                    InsertUser = table.Column<string>(nullable: true),
                    InsertDate = table.Column<DateTime>(nullable: true),
                    LastEditUser = table.Column<string>(nullable: true),
                    LastEditDate = table.Column<DateTime>(nullable: true),
                    EmpresaID = table.Column<long>(nullable: false),
                    UnidadeID = table.Column<long>(nullable: true),
                    Habilitado = table.Column<bool>(nullable: false),
                    Deletado = table.Column<bool>(nullable: false),
                    DeleteID = table.Column<long>(nullable: false),
                    IDProcesso = table.Column<Guid>(nullable: true),
                    FornecedorID = table.Column<long>(nullable: false),
                    DataEmissao = table.Column<DateTime>(nullable: false),
                    Observacao = table.Column<string>(nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Antecipacao", x => x.ID);
                    table.ForeignKey(
                        name: "FK_Antecipacao_Empresa_EmpresaID",
                        column: x => x.EmpresaID,
                        principalTable: "Empresa",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_Antecipacao_Fornecedor_FornecedorID",
                        column: x => x.FornecedorID,
                        principalTable: "Fornecedor",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_Antecipacao_Unidade_UnidadeID",
                        column: x => x.UnidadeID,
                        principalTable: "Unidade",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "DocumentoPagar",
                columns: table => new
                {
                    ID = table.Column<long>(nullable: false)
                        .Annotation("SqlServer:ValueGenerationStrategy", SqlServerValueGenerationStrategy.IdentityColumn),
                    InsertUser = table.Column<string>(nullable: true),
                    InsertDate = table.Column<DateTime>(nullable: true),
                    LastEditUser = table.Column<string>(nullable: true),
                    LastEditDate = table.Column<DateTime>(nullable: true),
                    EmpresaID = table.Column<long>(nullable: false),
                    UnidadeID = table.Column<long>(nullable: true),
                    Habilitado = table.Column<bool>(nullable: false),
                    Deletado = table.Column<bool>(nullable: false),
                    DeleteID = table.Column<long>(nullable: false),
                    IDProcesso = table.Column<Guid>(nullable: true),
                    OID = table.Column<Guid>(nullable: false),
                    FornecedorID = table.Column<long>(nullable: false),
                    NumeroDocumento = table.Column<string>(nullable: false),
                    Serie = table.Column<string>(nullable: true),
                    DataEmissao = table.Column<DateTime>(type: "Date", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_DocumentoPagar", x => x.ID);
                    table.ForeignKey(
                        name: "FK_DocumentoPagar_Empresa_EmpresaID",
                        column: x => x.EmpresaID,
                        principalTable: "Empresa",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_DocumentoPagar_Fornecedor_FornecedorID",
                        column: x => x.FornecedorID,
                        principalTable: "Fornecedor",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_DocumentoPagar_Unidade_UnidadeID",
                        column: x => x.UnidadeID,
                        principalTable: "Unidade",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "Sacado",
                columns: table => new
                {
                    ID = table.Column<long>(nullable: false)
                        .Annotation("SqlServer:ValueGenerationStrategy", SqlServerValueGenerationStrategy.IdentityColumn),
                    InsertUser = table.Column<string>(nullable: true),
                    InsertDate = table.Column<DateTime>(nullable: true),
                    LastEditUser = table.Column<string>(nullable: true),
                    LastEditDate = table.Column<DateTime>(nullable: true),
                    EmpresaID = table.Column<long>(nullable: false),
                    UnidadeID = table.Column<long>(nullable: true),
                    Habilitado = table.Column<bool>(nullable: false),
                    Deletado = table.Column<bool>(nullable: false),
                    DeleteID = table.Column<long>(nullable: false),
                    IDProcesso = table.Column<Guid>(nullable: true),
                    CPFCNPJ = table.Column<string>(nullable: false),
                    Nome = table.Column<string>(nullable: false),
                    Email = table.Column<string>(nullable: true),
                    Observacoes = table.Column<string>(nullable: true),
                    GrupoSacadoID = table.Column<long>(nullable: true),
                    CEP = table.Column<string>(nullable: false),
                    Logradouro = table.Column<string>(nullable: false),
                    Bairro = table.Column<string>(nullable: true),
                    UF = table.Column<string>(nullable: false),
                    Cidade = table.Column<string>(nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Sacado", x => x.ID);
                    table.ForeignKey(
                        name: "FK_Sacado_Empresa_EmpresaID",
                        column: x => x.EmpresaID,
                        principalTable: "Empresa",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_Sacado_GrupoSacado_GrupoSacadoID",
                        column: x => x.GrupoSacadoID,
                        principalTable: "GrupoSacado",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_Sacado_Unidade_UnidadeID",
                        column: x => x.UnidadeID,
                        principalTable: "Unidade",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "Usuario",
                columns: table => new
                {
                    ID = table.Column<long>(nullable: false)
                        .Annotation("SqlServer:ValueGenerationStrategy", SqlServerValueGenerationStrategy.IdentityColumn),
                    InsertUser = table.Column<string>(nullable: true),
                    InsertDate = table.Column<DateTime>(nullable: true),
                    LastEditUser = table.Column<string>(nullable: true),
                    LastEditDate = table.Column<DateTime>(nullable: true),
                    EmpresaID = table.Column<long>(nullable: false),
                    UnidadeID = table.Column<long>(nullable: true),
                    Habilitado = table.Column<bool>(nullable: false),
                    Deletado = table.Column<bool>(nullable: false),
                    DeleteID = table.Column<long>(nullable: false),
                    IDProcesso = table.Column<Guid>(nullable: true),
                    UserId = table.Column<string>(nullable: false),
                    Nome = table.Column<string>(nullable: true),
                    Email = table.Column<string>(nullable: true),
                    Senha = table.Column<string>(nullable: true),
                    UltimoAcesso = table.Column<DateTime>(nullable: true),
                    GrupoUsuarioID = table.Column<long>(nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Usuario", x => x.ID);
                    table.ForeignKey(
                        name: "FK_Usuario_Empresa_EmpresaID",
                        column: x => x.EmpresaID,
                        principalTable: "Empresa",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_Usuario_GrupoUsuario_GrupoUsuarioID",
                        column: x => x.GrupoUsuarioID,
                        principalTable: "GrupoUsuario",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_Usuario_Unidade_UnidadeID",
                        column: x => x.UnidadeID,
                        principalTable: "Unidade",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "Menu",
                columns: table => new
                {
                    ID = table.Column<long>(nullable: false)
                        .Annotation("SqlServer:ValueGenerationStrategy", SqlServerValueGenerationStrategy.IdentityColumn),
                    InsertUser = table.Column<string>(nullable: true),
                    InsertDate = table.Column<DateTime>(nullable: true),
                    LastEditUser = table.Column<string>(nullable: true),
                    LastEditDate = table.Column<DateTime>(nullable: true),
                    EmpresaID = table.Column<long>(nullable: false),
                    UnidadeID = table.Column<long>(nullable: true),
                    Habilitado = table.Column<bool>(nullable: false),
                    Deletado = table.Column<bool>(nullable: false),
                    DeleteID = table.Column<long>(nullable: false),
                    IDProcesso = table.Column<Guid>(nullable: true),
                    Nome = table.Column<string>(nullable: false),
                    Descricao = table.Column<string>(nullable: false),
                    Ordem = table.Column<int>(nullable: false),
                    ClasseIcone = table.Column<string>(nullable: true),
                    MenuSuperiorID = table.Column<long>(nullable: false),
                    ModuloID = table.Column<long>(nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Menu", x => x.ID);
                    table.ForeignKey(
                        name: "FK_Menu_Empresa_EmpresaID",
                        column: x => x.EmpresaID,
                        principalTable: "Empresa",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_Menu_Menu_MenuSuperiorID",
                        column: x => x.MenuSuperiorID,
                        principalTable: "Menu",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_Menu_Modulo_ModuloID",
                        column: x => x.ModuloID,
                        principalTable: "Modulo",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_Menu_Unidade_UnidadeID",
                        column: x => x.UnidadeID,
                        principalTable: "Unidade",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "Arquivo",
                columns: table => new
                {
                    ID = table.Column<long>(nullable: false)
                        .Annotation("SqlServer:ValueGenerationStrategy", SqlServerValueGenerationStrategy.IdentityColumn),
                    InsertUser = table.Column<string>(nullable: true),
                    InsertDate = table.Column<DateTime>(nullable: true),
                    LastEditUser = table.Column<string>(nullable: true),
                    LastEditDate = table.Column<DateTime>(nullable: true),
                    EmpresaID = table.Column<long>(nullable: false),
                    UnidadeID = table.Column<long>(nullable: true),
                    Habilitado = table.Column<bool>(nullable: false),
                    Deletado = table.Column<bool>(nullable: false),
                    DeleteID = table.Column<long>(nullable: false),
                    IDProcesso = table.Column<Guid>(nullable: true),
                    Nome = table.Column<string>(nullable: true),
                    Path = table.Column<string>(nullable: true),
                    CedenteID = table.Column<long>(nullable: true),
                    TipoOperacao = table.Column<int>(nullable: true),
                    TipoArquivo = table.Column<int>(nullable: true),
                    DirecaoArquivo = table.Column<int>(nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Arquivo", x => x.ID);
                    table.ForeignKey(
                        name: "FK_Arquivo_Cedente_CedenteID",
                        column: x => x.CedenteID,
                        principalTable: "Cedente",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_Arquivo_Empresa_EmpresaID",
                        column: x => x.EmpresaID,
                        principalTable: "Empresa",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_Arquivo_Unidade_UnidadeID",
                        column: x => x.UnidadeID,
                        principalTable: "Unidade",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "BancoAuth",
                columns: table => new
                {
                    ID = table.Column<long>(nullable: false)
                        .Annotation("SqlServer:ValueGenerationStrategy", SqlServerValueGenerationStrategy.IdentityColumn),
                    InsertUser = table.Column<string>(nullable: true),
                    InsertDate = table.Column<DateTime>(nullable: true),
                    LastEditUser = table.Column<string>(nullable: true),
                    LastEditDate = table.Column<DateTime>(nullable: true),
                    EmpresaID = table.Column<long>(nullable: false),
                    UnidadeID = table.Column<long>(nullable: true),
                    Habilitado = table.Column<bool>(nullable: false),
                    Deletado = table.Column<bool>(nullable: false),
                    DeleteID = table.Column<long>(nullable: false),
                    IDProcesso = table.Column<Guid>(nullable: true),
                    CedenteID = table.Column<long>(nullable: false),
                    MetodoBanco = table.Column<int>(nullable: false),
                    Homologacao = table.Column<bool>(nullable: false),
                    EndPoint = table.Column<string>(nullable: true),
                    Username = table.Column<string>(nullable: true),
                    Password = table.Column<string>(nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_BancoAuth", x => x.ID);
                    table.ForeignKey(
                        name: "FK_BancoAuth_Cedente_CedenteID",
                        column: x => x.CedenteID,
                        principalTable: "Cedente",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_BancoAuth_Empresa_EmpresaID",
                        column: x => x.EmpresaID,
                        principalTable: "Empresa",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_BancoAuth_Unidade_UnidadeID",
                        column: x => x.UnidadeID,
                        principalTable: "Unidade",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "ConfiguracaoArquivo",
                columns: table => new
                {
                    ID = table.Column<long>(nullable: false)
                        .Annotation("SqlServer:ValueGenerationStrategy", SqlServerValueGenerationStrategy.IdentityColumn),
                    InsertUser = table.Column<string>(nullable: true),
                    InsertDate = table.Column<DateTime>(nullable: true),
                    LastEditUser = table.Column<string>(nullable: true),
                    LastEditDate = table.Column<DateTime>(nullable: true),
                    EmpresaID = table.Column<long>(nullable: false),
                    UnidadeID = table.Column<long>(nullable: true),
                    Habilitado = table.Column<bool>(nullable: false),
                    Deletado = table.Column<bool>(nullable: false),
                    DeleteID = table.Column<long>(nullable: false),
                    IDProcesso = table.Column<Guid>(nullable: true),
                    CedenteID = table.Column<long>(nullable: false),
                    TipoOperacao = table.Column<int>(nullable: false),
                    TipoArquivo = table.Column<int>(nullable: false),
                    DirecaoArquivo = table.Column<int>(nullable: false),
                    NomeDiretorio = table.Column<string>(nullable: false),
                    NomeBase = table.Column<string>(nullable: true),
                    Extensao = table.Column<string>(nullable: true),
                    NumeroSequencial = table.Column<int>(nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ConfiguracaoArquivo", x => x.ID);
                    table.ForeignKey(
                        name: "FK_ConfiguracaoArquivo_Cedente_CedenteID",
                        column: x => x.CedenteID,
                        principalTable: "Cedente",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_ConfiguracaoArquivo_Empresa_EmpresaID",
                        column: x => x.EmpresaID,
                        principalTable: "Empresa",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_ConfiguracaoArquivo_Unidade_UnidadeID",
                        column: x => x.UnidadeID,
                        principalTable: "Unidade",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "LayoutEmail",
                columns: table => new
                {
                    ID = table.Column<long>(nullable: false)
                        .Annotation("SqlServer:ValueGenerationStrategy", SqlServerValueGenerationStrategy.IdentityColumn),
                    InsertUser = table.Column<string>(nullable: true),
                    InsertDate = table.Column<DateTime>(nullable: true),
                    LastEditUser = table.Column<string>(nullable: true),
                    LastEditDate = table.Column<DateTime>(nullable: true),
                    EmpresaID = table.Column<long>(nullable: false),
                    UnidadeID = table.Column<long>(nullable: true),
                    Habilitado = table.Column<bool>(nullable: false),
                    Deletado = table.Column<bool>(nullable: false),
                    DeleteID = table.Column<long>(nullable: false),
                    IDProcesso = table.Column<Guid>(nullable: true),
                    CedenteID = table.Column<long>(nullable: false),
                    TipoEmail = table.Column<int>(nullable: false),
                    Titulo = table.Column<string>(nullable: true),
                    BodyHtml = table.Column<byte[]>(nullable: true),
                    LinhasTabela01Html = table.Column<byte[]>(nullable: true),
                    LinkImagem01 = table.Column<string>(nullable: true),
                    LinkImagem02 = table.Column<string>(nullable: true),
                    LinkImagem03 = table.Column<string>(nullable: true),
                    LinkFaleConosco = table.Column<string>(nullable: true),
                    GeraDivSocial = table.Column<bool>(nullable: false),
                    LinkFacebook = table.Column<string>(nullable: true),
                    LinkInstagram = table.Column<string>(nullable: true),
                    LinkYoutube = table.Column<string>(nullable: true),
                    LinkPinterest = table.Column<string>(nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_LayoutEmail", x => x.ID);
                    table.ForeignKey(
                        name: "FK_LayoutEmail_Cedente_CedenteID",
                        column: x => x.CedenteID,
                        principalTable: "Cedente",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_LayoutEmail_Empresa_EmpresaID",
                        column: x => x.EmpresaID,
                        principalTable: "Empresa",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_LayoutEmail_Unidade_UnidadeID",
                        column: x => x.UnidadeID,
                        principalTable: "Unidade",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "TituloPagar",
                columns: table => new
                {
                    ID = table.Column<long>(nullable: false)
                        .Annotation("SqlServer:ValueGenerationStrategy", SqlServerValueGenerationStrategy.IdentityColumn),
                    InsertUser = table.Column<string>(nullable: true),
                    InsertDate = table.Column<DateTime>(nullable: true),
                    LastEditUser = table.Column<string>(nullable: true),
                    LastEditDate = table.Column<DateTime>(nullable: true),
                    EmpresaID = table.Column<long>(nullable: false),
                    UnidadeID = table.Column<long>(nullable: true),
                    Habilitado = table.Column<bool>(nullable: false),
                    Deletado = table.Column<bool>(nullable: false),
                    DeleteID = table.Column<long>(nullable: false),
                    IDProcesso = table.Column<Guid>(nullable: true),
                    OID = table.Column<Guid>(nullable: false),
                    DocumentoPagarID = table.Column<long>(nullable: false),
                    FaturaPagamentoID = table.Column<long>(nullable: true),
                    NumeroDocumento = table.Column<string>(nullable: false),
                    Parcela = table.Column<int>(nullable: false),
                    DataEmissao = table.Column<DateTime>(type: "Date", nullable: false),
                    DataVencimento = table.Column<DateTime>(type: "Date", nullable: false),
                    DataBaixa = table.Column<DateTime>(nullable: true),
                    FormaPagamento = table.Column<int>(nullable: true),
                    DataPagamento = table.Column<DateTime>(type: "Date", nullable: true),
                    ValorTitulo = table.Column<decimal>(nullable: false),
                    Saldo = table.Column<decimal>(nullable: false),
                    NumeroControleParticipante = table.Column<string>(nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_TituloPagar", x => x.ID);
                    table.ForeignKey(
                        name: "FK_TituloPagar_DocumentoPagar_DocumentoPagarID",
                        column: x => x.DocumentoPagarID,
                        principalTable: "DocumentoPagar",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_TituloPagar_Empresa_EmpresaID",
                        column: x => x.EmpresaID,
                        principalTable: "Empresa",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_TituloPagar_DocumentoPagar_FaturaPagamentoID",
                        column: x => x.FaturaPagamentoID,
                        principalTable: "DocumentoPagar",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_TituloPagar_Unidade_UnidadeID",
                        column: x => x.UnidadeID,
                        principalTable: "Unidade",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "Boleto",
                columns: table => new
                {
                    ID = table.Column<long>(nullable: false)
                        .Annotation("SqlServer:ValueGenerationStrategy", SqlServerValueGenerationStrategy.IdentityColumn),
                    InsertUser = table.Column<string>(nullable: true),
                    InsertDate = table.Column<DateTime>(nullable: true),
                    LastEditUser = table.Column<string>(nullable: true),
                    LastEditDate = table.Column<DateTime>(nullable: true),
                    EmpresaID = table.Column<long>(nullable: false),
                    UnidadeID = table.Column<long>(nullable: true),
                    Habilitado = table.Column<bool>(nullable: false),
                    Deletado = table.Column<bool>(nullable: false),
                    DeleteID = table.Column<long>(nullable: false),
                    IDProcesso = table.Column<Guid>(nullable: true),
                    OID = table.Column<Guid>(nullable: false),
                    CodigoBanco = table.Column<string>(maxLength: 3, nullable: false),
                    BancoID = table.Column<long>(nullable: false),
                    TipoOperacao = table.Column<int>(nullable: false),
                    FormaPagamento = table.Column<int>(nullable: false),
                    CedenteID = table.Column<long>(nullable: false),
                    SacadoID = table.Column<long>(nullable: false),
                    DataEmissao = table.Column<DateTime>(type: "Date", nullable: false),
                    DataProcessamento = table.Column<DateTime>(type: "Date", nullable: true),
                    DataVencimento = table.Column<DateTime>(type: "Date", nullable: false),
                    DataCredito = table.Column<DateTime>(type: "Date", nullable: true),
                    ValorTitulo = table.Column<decimal>(nullable: false),
                    ValorOutrosAcrescimos = table.Column<decimal>(nullable: true),
                    NumeroDocumento = table.Column<string>(nullable: true),
                    EspecieDocumento = table.Column<int>(nullable: true),
                    MensagemArquivoRemessa = table.Column<string>(nullable: true),
                    MensagemInstrucoesCaixa = table.Column<string>(nullable: true),
                    NumeroControleParticipante = table.Column<string>(nullable: true),
                    LoteID = table.Column<long>(nullable: true),
                    NossoNumero = table.Column<string>(nullable: false),
                    NossoNumeroDV = table.Column<string>(nullable: true),
                    NossoNumeroFormatado = table.Column<string>(nullable: true),
                    CodigoDeBarras = table.Column<string>(nullable: true),
                    LinhaDigitavel = table.Column<string>(nullable: true),
                    CampoLivre = table.Column<string>(nullable: true),
                    FatorVencimento = table.Column<long>(nullable: false),
                    DigitoVerificador = table.Column<string>(nullable: true),
                    CodigoMoeda = table.Column<int>(nullable: false),
                    EspecieMoeda = table.Column<string>(nullable: true),
                    QuantidadeMoeda = table.Column<int>(nullable: false),
                    ValorMoeda = table.Column<string>(nullable: true),
                    TipoCarteira = table.Column<int>(nullable: true),
                    Carteira = table.Column<string>(nullable: true),
                    VariacaoCarteira = table.Column<string>(nullable: true),
                    Aceite = table.Column<string>(nullable: true),
                    UsoBanco = table.Column<string>(nullable: true),
                    CodigoInstrucao1 = table.Column<string>(nullable: true),
                    CodigoInstrucao2 = table.Column<string>(nullable: true),
                    DataDesconto = table.Column<DateTime>(type: "Date", nullable: true),
                    ValorDesconto = table.Column<decimal>(nullable: true),
                    DataMulta = table.Column<DateTime>(type: "Date", nullable: true),
                    PercentualMulta = table.Column<decimal>(nullable: true),
                    ValorMulta = table.Column<decimal>(nullable: true),
                    DataJuros = table.Column<DateTime>(type: "Date", nullable: true),
                    PercentualJurosDia = table.Column<decimal>(nullable: true),
                    ValorJurosDia = table.Column<decimal>(nullable: true),
                    CodigoProtesto = table.Column<int>(nullable: true),
                    DiasProtesto = table.Column<int>(nullable: true),
                    EnviarEmailSacado = table.Column<bool>(nullable: false),
                    EnviarEmailCedente = table.Column<bool>(nullable: false),
                    RegistroOnline = table.Column<bool>(nullable: false),
                    StatusAPIRegistro = table.Column<int>(nullable: false),
                    MensagemRetornoAPI = table.Column<string>(nullable: true),
                    EmailEnviado = table.Column<bool>(nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Boleto", x => x.ID);
                    table.ForeignKey(
                        name: "FK_Boleto_Banco_BancoID",
                        column: x => x.BancoID,
                        principalTable: "Banco",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_Boleto_Cedente_CedenteID",
                        column: x => x.CedenteID,
                        principalTable: "Cedente",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_Boleto_Empresa_EmpresaID",
                        column: x => x.EmpresaID,
                        principalTable: "Empresa",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_Boleto_Lote_LoteID",
                        column: x => x.LoteID,
                        principalTable: "Lote",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_Boleto_Sacado_SacadoID",
                        column: x => x.SacadoID,
                        principalTable: "Sacado",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_Boleto_Unidade_UnidadeID",
                        column: x => x.UnidadeID,
                        principalTable: "Unidade",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "AccessToken",
                columns: table => new
                {
                    ID = table.Column<long>(nullable: false)
                        .Annotation("SqlServer:ValueGenerationStrategy", SqlServerValueGenerationStrategy.IdentityColumn),
                    InsertUser = table.Column<string>(nullable: true),
                    InsertDate = table.Column<DateTime>(nullable: true),
                    LastEditUser = table.Column<string>(nullable: true),
                    LastEditDate = table.Column<DateTime>(nullable: true),
                    UsuarioID = table.Column<long>(nullable: false),
                    DataHoraVencimento = table.Column<DateTime>(nullable: false),
                    TipoToken = table.Column<int>(nullable: false),
                    Chave = table.Column<string>(nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_AccessToken", x => x.ID);
                    table.ForeignKey(
                        name: "FK_AccessToken_Usuario_UsuarioID",
                        column: x => x.UsuarioID,
                        principalTable: "Usuario",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "UsuarioFornecedor",
                columns: table => new
                {
                    ID = table.Column<long>(nullable: false)
                        .Annotation("SqlServer:ValueGenerationStrategy", SqlServerValueGenerationStrategy.IdentityColumn),
                    InsertUser = table.Column<string>(nullable: true),
                    InsertDate = table.Column<DateTime>(nullable: true),
                    LastEditUser = table.Column<string>(nullable: true),
                    LastEditDate = table.Column<DateTime>(nullable: true),
                    EmpresaID = table.Column<long>(nullable: false),
                    UnidadeID = table.Column<long>(nullable: true),
                    Habilitado = table.Column<bool>(nullable: false),
                    Deletado = table.Column<bool>(nullable: false),
                    DeleteID = table.Column<long>(nullable: false),
                    IDProcesso = table.Column<Guid>(nullable: true),
                    UsuarioID = table.Column<long>(nullable: false),
                    FornecedorID = table.Column<long>(nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_UsuarioFornecedor", x => x.ID);
                    table.ForeignKey(
                        name: "FK_UsuarioFornecedor_Empresa_EmpresaID",
                        column: x => x.EmpresaID,
                        principalTable: "Empresa",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_UsuarioFornecedor_Fornecedor_FornecedorID",
                        column: x => x.FornecedorID,
                        principalTable: "Fornecedor",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_UsuarioFornecedor_Unidade_UnidadeID",
                        column: x => x.UnidadeID,
                        principalTable: "Unidade",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_UsuarioFornecedor_Usuario_UsuarioID",
                        column: x => x.UsuarioID,
                        principalTable: "Usuario",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "UsuarioSacado",
                columns: table => new
                {
                    ID = table.Column<long>(nullable: false)
                        .Annotation("SqlServer:ValueGenerationStrategy", SqlServerValueGenerationStrategy.IdentityColumn),
                    InsertUser = table.Column<string>(nullable: true),
                    InsertDate = table.Column<DateTime>(nullable: true),
                    LastEditUser = table.Column<string>(nullable: true),
                    LastEditDate = table.Column<DateTime>(nullable: true),
                    EmpresaID = table.Column<long>(nullable: false),
                    UnidadeID = table.Column<long>(nullable: true),
                    Habilitado = table.Column<bool>(nullable: false),
                    Deletado = table.Column<bool>(nullable: false),
                    DeleteID = table.Column<long>(nullable: false),
                    IDProcesso = table.Column<Guid>(nullable: true),
                    UsuarioID = table.Column<long>(nullable: false),
                    SacadoID = table.Column<long>(nullable: true),
                    GrupoSacadoID = table.Column<long>(nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_UsuarioSacado", x => x.ID);
                    table.ForeignKey(
                        name: "FK_UsuarioSacado_Empresa_EmpresaID",
                        column: x => x.EmpresaID,
                        principalTable: "Empresa",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_UsuarioSacado_GrupoSacado_GrupoSacadoID",
                        column: x => x.GrupoSacadoID,
                        principalTable: "GrupoSacado",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_UsuarioSacado_Sacado_SacadoID",
                        column: x => x.SacadoID,
                        principalTable: "Sacado",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_UsuarioSacado_Unidade_UnidadeID",
                        column: x => x.UnidadeID,
                        principalTable: "Unidade",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_UsuarioSacado_Usuario_UsuarioID",
                        column: x => x.UsuarioID,
                        principalTable: "Usuario",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "MenuAcao",
                columns: table => new
                {
                    ID = table.Column<long>(nullable: false)
                        .Annotation("SqlServer:ValueGenerationStrategy", SqlServerValueGenerationStrategy.IdentityColumn),
                    InsertUser = table.Column<string>(nullable: true),
                    InsertDate = table.Column<DateTime>(nullable: true),
                    LastEditUser = table.Column<string>(nullable: true),
                    LastEditDate = table.Column<DateTime>(nullable: true),
                    EmpresaID = table.Column<long>(nullable: false),
                    UnidadeID = table.Column<long>(nullable: true),
                    Habilitado = table.Column<bool>(nullable: false),
                    Deletado = table.Column<bool>(nullable: false),
                    DeleteID = table.Column<long>(nullable: false),
                    IDProcesso = table.Column<Guid>(nullable: true),
                    MenuID = table.Column<long>(nullable: false),
                    AcaoID = table.Column<long>(nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_MenuAcao", x => x.ID);
                    table.ForeignKey(
                        name: "FK_MenuAcao_Acao_AcaoID",
                        column: x => x.AcaoID,
                        principalTable: "Acao",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_MenuAcao_Empresa_EmpresaID",
                        column: x => x.EmpresaID,
                        principalTable: "Empresa",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_MenuAcao_Menu_MenuID",
                        column: x => x.MenuID,
                        principalTable: "Menu",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_MenuAcao_Unidade_UnidadeID",
                        column: x => x.UnidadeID,
                        principalTable: "Unidade",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "Permissao",
                columns: table => new
                {
                    ID = table.Column<long>(nullable: false)
                        .Annotation("SqlServer:ValueGenerationStrategy", SqlServerValueGenerationStrategy.IdentityColumn),
                    InsertUser = table.Column<string>(nullable: true),
                    InsertDate = table.Column<DateTime>(nullable: true),
                    LastEditUser = table.Column<string>(nullable: true),
                    LastEditDate = table.Column<DateTime>(nullable: true),
                    EmpresaID = table.Column<long>(nullable: false),
                    UnidadeID = table.Column<long>(nullable: true),
                    Habilitado = table.Column<bool>(nullable: false),
                    Deletado = table.Column<bool>(nullable: false),
                    DeleteID = table.Column<long>(nullable: false),
                    IDProcesso = table.Column<Guid>(nullable: true),
                    GrupoUsuarioID = table.Column<long>(nullable: false),
                    MenuID = table.Column<long>(nullable: false),
                    AcaoID = table.Column<long>(nullable: false),
                    Acesso = table.Column<string>(nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Permissao", x => x.ID);
                    table.ForeignKey(
                        name: "FK_Permissao_Acao_AcaoID",
                        column: x => x.AcaoID,
                        principalTable: "Acao",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_Permissao_Empresa_EmpresaID",
                        column: x => x.EmpresaID,
                        principalTable: "Empresa",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_Permissao_GrupoUsuario_GrupoUsuarioID",
                        column: x => x.GrupoUsuarioID,
                        principalTable: "GrupoUsuario",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_Permissao_Menu_MenuID",
                        column: x => x.MenuID,
                        principalTable: "Menu",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_Permissao_Unidade_UnidadeID",
                        column: x => x.UnidadeID,
                        principalTable: "Unidade",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "Registro",
                columns: table => new
                {
                    ID = table.Column<long>(nullable: false)
                        .Annotation("SqlServer:ValueGenerationStrategy", SqlServerValueGenerationStrategy.IdentityColumn),
                    InsertUser = table.Column<string>(nullable: true),
                    InsertDate = table.Column<DateTime>(nullable: true),
                    LastEditUser = table.Column<string>(nullable: true),
                    LastEditDate = table.Column<DateTime>(nullable: true),
                    EmpresaID = table.Column<long>(nullable: false),
                    UnidadeID = table.Column<long>(nullable: true),
                    Habilitado = table.Column<bool>(nullable: false),
                    Deletado = table.Column<bool>(nullable: false),
                    DeleteID = table.Column<long>(nullable: false),
                    IDProcesso = table.Column<Guid>(nullable: true),
                    ArquivoID = table.Column<long>(nullable: false),
                    TituloOID = table.Column<Guid>(nullable: true),
                    TipoRegistro = table.Column<string>(nullable: true),
                    Segmento = table.Column<string>(nullable: true),
                    Pessoa_CPFCNPJ = table.Column<string>(nullable: true),
                    Pessoa_Nome = table.Column<string>(nullable: true),
                    Pessoa_CodigoBanco = table.Column<string>(nullable: true),
                    Pessoa_Agencia = table.Column<string>(nullable: true),
                    Pessoa_DigitoAgencia = table.Column<string>(nullable: true),
                    Pessoa_Conta = table.Column<string>(nullable: true),
                    Pessoa_DigitoConta = table.Column<string>(nullable: true),
                    Pessoa_SegundoDigitoConta = table.Column<string>(nullable: true),
                    NumeroControleParticipante = table.Column<string>(nullable: true),
                    CodigoBarras = table.Column<string>(nullable: true),
                    Especie = table.Column<int>(nullable: false),
                    DataEmissao = table.Column<DateTime>(nullable: true),
                    DataVencimento = table.Column<DateTime>(nullable: true),
                    ValorTitulo = table.Column<decimal>(nullable: true),
                    CodigoOcorrencia = table.Column<string>(nullable: true),
                    DescricaoOcorrencia = table.Column<string>(nullable: true),
                    CodigoOcorrenciaAuxiliar = table.Column<string>(nullable: true),
                    CodigoCamaraCentralizadora = table.Column<string>(nullable: true),
                    OcorrenciasRetorno = table.Column<string>(nullable: true),
                    NossoNumero = table.Column<string>(nullable: true),
                    NumeroDocumento = table.Column<string>(nullable: true),
                    ValorTarifas = table.Column<decimal>(nullable: true),
                    ValorOutrasDespesas = table.Column<decimal>(nullable: true),
                    ValorIOF = table.Column<decimal>(nullable: true),
                    ValorAbatimento = table.Column<decimal>(nullable: true),
                    ValorDesconto = table.Column<decimal>(nullable: true),
                    ValorPago = table.Column<decimal>(nullable: true),
                    ValorJurosDia = table.Column<decimal>(nullable: true),
                    ValorOutrosCreditos = table.Column<decimal>(nullable: true),
                    ValorMulta = table.Column<decimal>(nullable: true),
                    ValorAtualizacaoMonetaria = table.Column<decimal>(nullable: true),
                    ValorJuros = table.Column<decimal>(nullable: true),
                    ValorTotal = table.Column<decimal>(nullable: true),
                    DataProcessamento = table.Column<DateTime>(nullable: true),
                    DataCredito = table.Column<DateTime>(nullable: true),
                    CodigoUF = table.Column<string>(nullable: true),
                    IdentificadorGuia = table.Column<string>(nullable: true),
                    CodigoReceita = table.Column<string>(nullable: true),
                    PeriodoReferencia = table.Column<string>(nullable: true),
                    AutorizacaoDebito = table.Column<string>(nullable: true),
                    NumeroAgendamentoRemessa = table.Column<string>(nullable: true),
                    DataAgendamento = table.Column<DateTime>(nullable: true),
                    AutenticacaoBancaria = table.Column<string>(nullable: true),
                    Natureza = table.Column<string>(nullable: true),
                    TipoComplemento = table.Column<string>(nullable: true),
                    Complemento = table.Column<string>(nullable: true),
                    DataContabil = table.Column<DateTime>(nullable: true),
                    DataLancamento = table.Column<DateTime>(nullable: true),
                    TipoLancamento = table.Column<string>(nullable: true),
                    Categoria = table.Column<string>(nullable: true),
                    CodigoHistorico = table.Column<string>(nullable: true),
                    DescricaoHistorico = table.Column<string>(nullable: true),
                    RegistroArquivoRetorno = table.Column<string>(nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Registro", x => x.ID);
                    table.ForeignKey(
                        name: "FK_Registro_Arquivo_ArquivoID",
                        column: x => x.ArquivoID,
                        principalTable: "Arquivo",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_Registro_Empresa_EmpresaID",
                        column: x => x.EmpresaID,
                        principalTable: "Empresa",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_Registro_Unidade_UnidadeID",
                        column: x => x.UnidadeID,
                        principalTable: "Unidade",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "AntecipacaoItem",
                columns: table => new
                {
                    ID = table.Column<long>(nullable: false)
                        .Annotation("SqlServer:ValueGenerationStrategy", SqlServerValueGenerationStrategy.IdentityColumn),
                    InsertUser = table.Column<string>(nullable: true),
                    InsertDate = table.Column<DateTime>(nullable: true),
                    LastEditUser = table.Column<string>(nullable: true),
                    LastEditDate = table.Column<DateTime>(nullable: true),
                    EmpresaID = table.Column<long>(nullable: false),
                    UnidadeID = table.Column<long>(nullable: true),
                    Habilitado = table.Column<bool>(nullable: false),
                    Deletado = table.Column<bool>(nullable: false),
                    DeleteID = table.Column<long>(nullable: false),
                    IDProcesso = table.Column<Guid>(nullable: true),
                    TituloPagarID = table.Column<long>(nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_AntecipacaoItem", x => x.ID);
                    table.ForeignKey(
                        name: "FK_AntecipacaoItem_Empresa_EmpresaID",
                        column: x => x.EmpresaID,
                        principalTable: "Empresa",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_AntecipacaoItem_TituloPagar_TituloPagarID",
                        column: x => x.TituloPagarID,
                        principalTable: "TituloPagar",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_AntecipacaoItem_Unidade_UnidadeID",
                        column: x => x.UnidadeID,
                        principalTable: "Unidade",
                        principalColumn: "ID",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateIndex(
                name: "IX_Acao_EmpresaID",
                table: "Acao",
                column: "EmpresaID");

            migrationBuilder.CreateIndex(
                name: "IX_Acao_UnidadeID",
                table: "Acao",
                column: "UnidadeID");

            migrationBuilder.CreateIndex(
                name: "IX_AccessToken_UsuarioID",
                table: "AccessToken",
                column: "UsuarioID");

            migrationBuilder.CreateIndex(
                name: "IX_Antecipacao_EmpresaID",
                table: "Antecipacao",
                column: "EmpresaID");

            migrationBuilder.CreateIndex(
                name: "IX_Antecipacao_FornecedorID",
                table: "Antecipacao",
                column: "FornecedorID");

            migrationBuilder.CreateIndex(
                name: "IX_Antecipacao_UnidadeID",
                table: "Antecipacao",
                column: "UnidadeID");

            migrationBuilder.CreateIndex(
                name: "IX_AntecipacaoItem_EmpresaID",
                table: "AntecipacaoItem",
                column: "EmpresaID");

            migrationBuilder.CreateIndex(
                name: "IX_AntecipacaoItem_TituloPagarID",
                table: "AntecipacaoItem",
                column: "TituloPagarID");

            migrationBuilder.CreateIndex(
                name: "IX_AntecipacaoItem_UnidadeID",
                table: "AntecipacaoItem",
                column: "UnidadeID");

            migrationBuilder.CreateIndex(
                name: "IX_Arquivo_CedenteID",
                table: "Arquivo",
                column: "CedenteID");

            migrationBuilder.CreateIndex(
                name: "IX_Arquivo_EmpresaID",
                table: "Arquivo",
                column: "EmpresaID");

            migrationBuilder.CreateIndex(
                name: "IX_Arquivo_UnidadeID",
                table: "Arquivo",
                column: "UnidadeID");

            migrationBuilder.CreateIndex(
                name: "IX_Banco_Codigo",
                table: "Banco",
                column: "Codigo",
                unique: true,
                filter: "[Codigo] IS NOT NULL");

            migrationBuilder.CreateIndex(
                name: "IX_BancoAuth_CedenteID",
                table: "BancoAuth",
                column: "CedenteID");

            migrationBuilder.CreateIndex(
                name: "IX_BancoAuth_EmpresaID",
                table: "BancoAuth",
                column: "EmpresaID");

            migrationBuilder.CreateIndex(
                name: "IX_BancoAuth_UnidadeID",
                table: "BancoAuth",
                column: "UnidadeID");

            migrationBuilder.CreateIndex(
                name: "IX_Boleto_BancoID",
                table: "Boleto",
                column: "BancoID");

            migrationBuilder.CreateIndex(
                name: "IX_Boleto_CedenteID",
                table: "Boleto",
                column: "CedenteID");

            migrationBuilder.CreateIndex(
                name: "IX_Boleto_EmpresaID",
                table: "Boleto",
                column: "EmpresaID");

            migrationBuilder.CreateIndex(
                name: "IX_Boleto_LoteID",
                table: "Boleto",
                column: "LoteID");

            migrationBuilder.CreateIndex(
                name: "IX_Boleto_SacadoID",
                table: "Boleto",
                column: "SacadoID");

            migrationBuilder.CreateIndex(
                name: "IX_Boleto_UnidadeID",
                table: "Boleto",
                column: "UnidadeID");

            migrationBuilder.CreateIndex(
                name: "IX_Cedente_ContaBancariaID",
                table: "Cedente",
                column: "ContaBancariaID");

            migrationBuilder.CreateIndex(
                name: "IX_Cedente_EmpresaID",
                table: "Cedente",
                column: "EmpresaID");

            migrationBuilder.CreateIndex(
                name: "IX_Cedente_UnidadeID",
                table: "Cedente",
                column: "UnidadeID");

            migrationBuilder.CreateIndex(
                name: "IX_Cedente_CPFCNPJ_Codigo",
                table: "Cedente",
                columns: new[] { "CPFCNPJ", "Codigo" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_ConfiguracaoArquivo_CedenteID",
                table: "ConfiguracaoArquivo",
                column: "CedenteID");

            migrationBuilder.CreateIndex(
                name: "IX_ConfiguracaoArquivo_EmpresaID",
                table: "ConfiguracaoArquivo",
                column: "EmpresaID");

            migrationBuilder.CreateIndex(
                name: "IX_ConfiguracaoArquivo_UnidadeID",
                table: "ConfiguracaoArquivo",
                column: "UnidadeID");

            migrationBuilder.CreateIndex(
                name: "IX_ContaBancaria_BancoID",
                table: "ContaBancaria",
                column: "BancoID");

            migrationBuilder.CreateIndex(
                name: "IX_ContaBancaria_EmpresaID",
                table: "ContaBancaria",
                column: "EmpresaID");

            migrationBuilder.CreateIndex(
                name: "IX_ContaBancaria_UnidadeID",
                table: "ContaBancaria",
                column: "UnidadeID");

            migrationBuilder.CreateIndex(
                name: "IX_DocumentoPagar_EmpresaID",
                table: "DocumentoPagar",
                column: "EmpresaID");

            migrationBuilder.CreateIndex(
                name: "IX_DocumentoPagar_FornecedorID",
                table: "DocumentoPagar",
                column: "FornecedorID");

            migrationBuilder.CreateIndex(
                name: "IX_DocumentoPagar_UnidadeID",
                table: "DocumentoPagar",
                column: "UnidadeID");

            migrationBuilder.CreateIndex(
                name: "IX_Empresa_Client_Key",
                table: "Empresa",
                column: "Client_Key",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Fornecedor_EmpresaID",
                table: "Fornecedor",
                column: "EmpresaID");

            migrationBuilder.CreateIndex(
                name: "IX_Fornecedor_UnidadeID",
                table: "Fornecedor",
                column: "UnidadeID");

            migrationBuilder.CreateIndex(
                name: "IX_GrupoSacado_EmpresaID",
                table: "GrupoSacado",
                column: "EmpresaID");

            migrationBuilder.CreateIndex(
                name: "IX_GrupoSacado_UnidadeID",
                table: "GrupoSacado",
                column: "UnidadeID");

            migrationBuilder.CreateIndex(
                name: "IX_GrupoUsuario_EmpresaID",
                table: "GrupoUsuario",
                column: "EmpresaID");

            migrationBuilder.CreateIndex(
                name: "IX_GrupoUsuario_UnidadeID",
                table: "GrupoUsuario",
                column: "UnidadeID");

            migrationBuilder.CreateIndex(
                name: "IX_LayoutEmail_CedenteID",
                table: "LayoutEmail",
                column: "CedenteID");

            migrationBuilder.CreateIndex(
                name: "IX_LayoutEmail_EmpresaID",
                table: "LayoutEmail",
                column: "EmpresaID");

            migrationBuilder.CreateIndex(
                name: "IX_LayoutEmail_UnidadeID",
                table: "LayoutEmail",
                column: "UnidadeID");

            migrationBuilder.CreateIndex(
                name: "IX_Lote_EmpresaID",
                table: "Lote",
                column: "EmpresaID");

            migrationBuilder.CreateIndex(
                name: "IX_Lote_UnidadeID",
                table: "Lote",
                column: "UnidadeID");

            migrationBuilder.CreateIndex(
                name: "IX_Mail_EmpresaID",
                table: "Mail",
                column: "EmpresaID");

            migrationBuilder.CreateIndex(
                name: "IX_Mail_UnidadeID",
                table: "Mail",
                column: "UnidadeID");

            migrationBuilder.CreateIndex(
                name: "IX_Menu_EmpresaID",
                table: "Menu",
                column: "EmpresaID");

            migrationBuilder.CreateIndex(
                name: "IX_Menu_MenuSuperiorID",
                table: "Menu",
                column: "MenuSuperiorID");

            migrationBuilder.CreateIndex(
                name: "IX_Menu_ModuloID",
                table: "Menu",
                column: "ModuloID");

            migrationBuilder.CreateIndex(
                name: "IX_Menu_UnidadeID",
                table: "Menu",
                column: "UnidadeID");

            migrationBuilder.CreateIndex(
                name: "IX_MenuAcao_AcaoID",
                table: "MenuAcao",
                column: "AcaoID");

            migrationBuilder.CreateIndex(
                name: "IX_MenuAcao_EmpresaID",
                table: "MenuAcao",
                column: "EmpresaID");

            migrationBuilder.CreateIndex(
                name: "IX_MenuAcao_MenuID",
                table: "MenuAcao",
                column: "MenuID");

            migrationBuilder.CreateIndex(
                name: "IX_MenuAcao_UnidadeID",
                table: "MenuAcao",
                column: "UnidadeID");

            migrationBuilder.CreateIndex(
                name: "IX_Modulo_EmpresaID",
                table: "Modulo",
                column: "EmpresaID");

            migrationBuilder.CreateIndex(
                name: "IX_Modulo_UnidadeID",
                table: "Modulo",
                column: "UnidadeID");

            migrationBuilder.CreateIndex(
                name: "IX_Permissao_AcaoID",
                table: "Permissao",
                column: "AcaoID");

            migrationBuilder.CreateIndex(
                name: "IX_Permissao_EmpresaID",
                table: "Permissao",
                column: "EmpresaID");

            migrationBuilder.CreateIndex(
                name: "IX_Permissao_GrupoUsuarioID",
                table: "Permissao",
                column: "GrupoUsuarioID");

            migrationBuilder.CreateIndex(
                name: "IX_Permissao_MenuID",
                table: "Permissao",
                column: "MenuID");

            migrationBuilder.CreateIndex(
                name: "IX_Permissao_UnidadeID",
                table: "Permissao",
                column: "UnidadeID");

            migrationBuilder.CreateIndex(
                name: "IX_Registro_ArquivoID",
                table: "Registro",
                column: "ArquivoID");

            migrationBuilder.CreateIndex(
                name: "IX_Registro_EmpresaID",
                table: "Registro",
                column: "EmpresaID");

            migrationBuilder.CreateIndex(
                name: "IX_Registro_UnidadeID",
                table: "Registro",
                column: "UnidadeID");

            migrationBuilder.CreateIndex(
                name: "IX_Sacado_GrupoSacadoID",
                table: "Sacado",
                column: "GrupoSacadoID");

            migrationBuilder.CreateIndex(
                name: "IX_Sacado_UnidadeID",
                table: "Sacado",
                column: "UnidadeID");

            migrationBuilder.CreateIndex(
                name: "IX_Sacado_EmpresaID_UnidadeID_CPFCNPJ",
                table: "Sacado",
                columns: new[] { "EmpresaID", "UnidadeID", "CPFCNPJ" },
                unique: true,
                filter: "[UnidadeID] IS NOT NULL");

            migrationBuilder.CreateIndex(
                name: "IX_TituloPagar_DocumentoPagarID",
                table: "TituloPagar",
                column: "DocumentoPagarID");

            migrationBuilder.CreateIndex(
                name: "IX_TituloPagar_EmpresaID",
                table: "TituloPagar",
                column: "EmpresaID");

            migrationBuilder.CreateIndex(
                name: "IX_TituloPagar_FaturaPagamentoID",
                table: "TituloPagar",
                column: "FaturaPagamentoID");

            migrationBuilder.CreateIndex(
                name: "IX_TituloPagar_UnidadeID",
                table: "TituloPagar",
                column: "UnidadeID");

            migrationBuilder.CreateIndex(
                name: "IX_Unidade_CNPJ",
                table: "Unidade",
                column: "CNPJ",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Unidade_EmpresaID",
                table: "Unidade",
                column: "EmpresaID");

            migrationBuilder.CreateIndex(
                name: "IX_Unidade_UnidadeID",
                table: "Unidade",
                column: "UnidadeID");

            migrationBuilder.CreateIndex(
                name: "IX_Usuario_EmpresaID",
                table: "Usuario",
                column: "EmpresaID");

            migrationBuilder.CreateIndex(
                name: "IX_Usuario_GrupoUsuarioID",
                table: "Usuario",
                column: "GrupoUsuarioID");

            migrationBuilder.CreateIndex(
                name: "IX_Usuario_UnidadeID",
                table: "Usuario",
                column: "UnidadeID");

            migrationBuilder.CreateIndex(
                name: "IX_UsuarioFornecedor_EmpresaID",
                table: "UsuarioFornecedor",
                column: "EmpresaID");

            migrationBuilder.CreateIndex(
                name: "IX_UsuarioFornecedor_FornecedorID",
                table: "UsuarioFornecedor",
                column: "FornecedorID");

            migrationBuilder.CreateIndex(
                name: "IX_UsuarioFornecedor_UnidadeID",
                table: "UsuarioFornecedor",
                column: "UnidadeID");

            migrationBuilder.CreateIndex(
                name: "IX_UsuarioFornecedor_UsuarioID",
                table: "UsuarioFornecedor",
                column: "UsuarioID");

            migrationBuilder.CreateIndex(
                name: "IX_UsuarioSacado_EmpresaID",
                table: "UsuarioSacado",
                column: "EmpresaID");

            migrationBuilder.CreateIndex(
                name: "IX_UsuarioSacado_GrupoSacadoID",
                table: "UsuarioSacado",
                column: "GrupoSacadoID");

            migrationBuilder.CreateIndex(
                name: "IX_UsuarioSacado_SacadoID",
                table: "UsuarioSacado",
                column: "SacadoID");

            migrationBuilder.CreateIndex(
                name: "IX_UsuarioSacado_UnidadeID",
                table: "UsuarioSacado",
                column: "UnidadeID");

            migrationBuilder.CreateIndex(
                name: "IX_UsuarioSacado_UsuarioID",
                table: "UsuarioSacado",
                column: "UsuarioID");

            migrationBuilder.AddForeignKey(
                name: "FK_AspNetRoleClaims_AspNetRoles_RoleId",
                table: "AspNetRoleClaims",
                column: "RoleId",
                principalTable: "AspNetRoles",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_AspNetUserClaims_AspNetUsers_UserId",
                table: "AspNetUserClaims",
                column: "UserId",
                principalTable: "AspNetUsers",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_AspNetUserLogins_AspNetUsers_UserId",
                table: "AspNetUserLogins",
                column: "UserId",
                principalTable: "AspNetUsers",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_AspNetUserRoles_AspNetRoles_RoleId",
                table: "AspNetUserRoles",
                column: "RoleId",
                principalTable: "AspNetRoles",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_AspNetUserRoles_AspNetUsers_UserId",
                table: "AspNetUserRoles",
                column: "UserId",
                principalTable: "AspNetUsers",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_AspNetUserTokens_AspNetUsers_UserId",
                table: "AspNetUserTokens",
                column: "UserId",
                principalTable: "AspNetUsers",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_AspNetRoleClaims_AspNetRoles_RoleId",
                table: "AspNetRoleClaims");

            migrationBuilder.DropForeignKey(
                name: "FK_AspNetUserClaims_AspNetUsers_UserId",
                table: "AspNetUserClaims");

            migrationBuilder.DropForeignKey(
                name: "FK_AspNetUserLogins_AspNetUsers_UserId",
                table: "AspNetUserLogins");

            migrationBuilder.DropForeignKey(
                name: "FK_AspNetUserRoles_AspNetRoles_RoleId",
                table: "AspNetUserRoles");

            migrationBuilder.DropForeignKey(
                name: "FK_AspNetUserRoles_AspNetUsers_UserId",
                table: "AspNetUserRoles");

            migrationBuilder.DropForeignKey(
                name: "FK_AspNetUserTokens_AspNetUsers_UserId",
                table: "AspNetUserTokens");

            migrationBuilder.DropTable(
                name: "AccessToken");

            migrationBuilder.DropTable(
                name: "Antecipacao");

            migrationBuilder.DropTable(
                name: "AntecipacaoItem");

            migrationBuilder.DropTable(
                name: "BancoAuth");

            migrationBuilder.DropTable(
                name: "Boleto");

            migrationBuilder.DropTable(
                name: "ConfiguracaoArquivo");

            migrationBuilder.DropTable(
                name: "LayoutEmail");

            migrationBuilder.DropTable(
                name: "LogApi");

            migrationBuilder.DropTable(
                name: "LogApiHistorico");

            migrationBuilder.DropTable(
                name: "Mail");

            migrationBuilder.DropTable(
                name: "MenuAcao");

            migrationBuilder.DropTable(
                name: "Permissao");

            migrationBuilder.DropTable(
                name: "Registro");

            migrationBuilder.DropTable(
                name: "UsuarioFornecedor");

            migrationBuilder.DropTable(
                name: "UsuarioSacado");

            migrationBuilder.DropTable(
                name: "TituloPagar");

            migrationBuilder.DropTable(
                name: "Lote");

            migrationBuilder.DropTable(
                name: "Acao");

            migrationBuilder.DropTable(
                name: "Menu");

            migrationBuilder.DropTable(
                name: "Arquivo");

            migrationBuilder.DropTable(
                name: "Sacado");

            migrationBuilder.DropTable(
                name: "Usuario");

            migrationBuilder.DropTable(
                name: "DocumentoPagar");

            migrationBuilder.DropTable(
                name: "Modulo");

            migrationBuilder.DropTable(
                name: "Cedente");

            migrationBuilder.DropTable(
                name: "GrupoSacado");

            migrationBuilder.DropTable(
                name: "GrupoUsuario");

            migrationBuilder.DropTable(
                name: "Fornecedor");

            migrationBuilder.DropTable(
                name: "ContaBancaria");

            migrationBuilder.DropTable(
                name: "Banco");

            migrationBuilder.DropTable(
                name: "Unidade");

            migrationBuilder.DropTable(
                name: "Empresa");

            migrationBuilder.AddForeignKey(
                name: "FK_AspNetRoleClaims_AspNetRoles_RoleId",
                table: "AspNetRoleClaims",
                column: "RoleId",
                principalTable: "AspNetRoles",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_AspNetUserClaims_AspNetUsers_UserId",
                table: "AspNetUserClaims",
                column: "UserId",
                principalTable: "AspNetUsers",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_AspNetUserLogins_AspNetUsers_UserId",
                table: "AspNetUserLogins",
                column: "UserId",
                principalTable: "AspNetUsers",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_AspNetUserRoles_AspNetRoles_RoleId",
                table: "AspNetUserRoles",
                column: "RoleId",
                principalTable: "AspNetRoles",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_AspNetUserRoles_AspNetUsers_UserId",
                table: "AspNetUserRoles",
                column: "UserId",
                principalTable: "AspNetUsers",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_AspNetUserTokens_AspNetUsers_UserId",
                table: "AspNetUserTokens",
                column: "UserId",
                principalTable: "AspNetUsers",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);
        }
    }
}
