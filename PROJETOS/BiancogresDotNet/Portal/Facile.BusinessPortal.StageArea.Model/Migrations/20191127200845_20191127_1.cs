using System;
using Microsoft.EntityFrameworkCore.Metadata;
using Microsoft.EntityFrameworkCore.Migrations;

namespace Facile.BusinessPortal.StageArea.Model.Migrations
{
    public partial class _20191127_1 : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "Antecipacao",
                columns: table => new
                {
                    ID = table.Column<long>(nullable: false)
                        .Annotation("SqlServer:ValueGenerationStrategy", SqlServerValueGenerationStrategy.IdentityColumn),
                    ChaveUnica = table.Column<string>(nullable: false),
                    EmpresaID = table.Column<long>(nullable: false),
                    UnidadeID = table.Column<long>(nullable: true),
                    InsertUser = table.Column<string>(nullable: true),
                    InsertDate = table.Column<DateTime>(nullable: true),
                    LastEditUser = table.Column<string>(nullable: true),
                    LastEditDate = table.Column<DateTime>(nullable: true),
                    StatusIntegracao = table.Column<int>(nullable: false),
                    DataHoraIntegracao = table.Column<DateTime>(nullable: true),
                    MensagemRetorno = table.Column<string>(nullable: true),
                    FornecedorCPFCNPJ = table.Column<string>(nullable: true),
                    DataEmissao = table.Column<DateTime>(nullable: false),
                    DataRecebimento = table.Column<DateTime>(nullable: false),
                    Observacao = table.Column<string>(nullable: true),
                    Contato = table.Column<string>(nullable: true),
                    Taxa = table.Column<decimal>(nullable: false),
                    Origem = table.Column<int>(nullable: false),
                    Status = table.Column<int>(nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Antecipacao", x => x.ID);
                });

            migrationBuilder.CreateTable(
                name: "AntecipacaoItem",
                columns: table => new
                {
                    ID = table.Column<long>(nullable: false)
                        .Annotation("SqlServer:ValueGenerationStrategy", SqlServerValueGenerationStrategy.IdentityColumn),
                    ChaveUnica = table.Column<string>(nullable: false),
                    EmpresaID = table.Column<long>(nullable: false),
                    UnidadeID = table.Column<long>(nullable: true),
                    InsertUser = table.Column<string>(nullable: true),
                    InsertDate = table.Column<DateTime>(nullable: true),
                    LastEditUser = table.Column<string>(nullable: true),
                    LastEditDate = table.Column<DateTime>(nullable: true),
                    StatusIntegracao = table.Column<int>(nullable: false),
                    DataHoraIntegracao = table.Column<DateTime>(nullable: true),
                    MensagemRetorno = table.Column<string>(nullable: true),
                    AntecipacaoID = table.Column<long>(nullable: false),
                    TituloPagarID = table.Column<long>(nullable: false),
                    ValorTitulo = table.Column<decimal>(nullable: false),
                    ValorTituloAntecipado = table.Column<decimal>(nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_AntecipacaoItem", x => x.ID);
                });
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "Antecipacao");

            migrationBuilder.DropTable(
                name: "AntecipacaoItem");
        }
    }
}
