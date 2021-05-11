using System;
using Microsoft.EntityFrameworkCore.Metadata;
using Microsoft.EntityFrameworkCore.Migrations;

namespace Facile.BusinessPortal.StageArea.Model.Migrations
{
    public partial class _20191004_4 : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "TituloPagar",
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
                    NumeroDocumentoPagar = table.Column<string>(nullable: true),
                    SerieDocumentoPagar = table.Column<string>(nullable: true),
                    DataEmissaoDocumentoPagar = table.Column<DateTime>(nullable: false),
                    NumeroFaturaPagamento = table.Column<string>(nullable: true),
                    SerieFaturaPagamento = table.Column<string>(nullable: true),
                    DataEmissaoFaturaPagamento = table.Column<DateTime>(nullable: false),
                    NumeroDocumento = table.Column<string>(nullable: true),
                    Parcela = table.Column<string>(nullable: true),
                    DataEmissao = table.Column<DateTime>(nullable: false),
                    DataVencimento = table.Column<DateTime>(nullable: false),
                    DataBaixa = table.Column<DateTime>(nullable: true),
                    FormaPagamento = table.Column<string>(nullable: true),
                    DataPagamento = table.Column<DateTime>(nullable: true),
                    ValorTitulo = table.Column<decimal>(nullable: false),
                    Saldo = table.Column<decimal>(nullable: false),
                    NumeroControleParticipante = table.Column<string>(nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_TituloPagar", x => x.ID);
                });

            migrationBuilder.CreateIndex(
                name: "IX_TituloPagar_EmpresaID_ChaveUnica",
                table: "TituloPagar",
                columns: new[] { "EmpresaID", "ChaveUnica" },
                unique: true);
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "TituloPagar");
        }
    }
}
