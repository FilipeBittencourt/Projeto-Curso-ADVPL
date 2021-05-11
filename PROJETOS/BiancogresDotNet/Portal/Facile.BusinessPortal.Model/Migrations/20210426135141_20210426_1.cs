using Microsoft.EntityFrameworkCore.Migrations;

namespace Facile.BusinessPortal.Model.Migrations
{
    public partial class _20210426_1 : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "ItemAE",
                table: "SolicitacaoServicoMedicaoItem",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "NumeroAE",
                table: "SolicitacaoServicoMedicaoItem",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "CodigoCliente",
                table: "SolicitacaoServicoItem",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "Descricao",
                table: "SolicitacaoServico",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "ClassificacaoFiscal",
                table: "Produto",
                nullable: true);
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "ItemAE",
                table: "SolicitacaoServicoMedicaoItem");

            migrationBuilder.DropColumn(
                name: "NumeroAE",
                table: "SolicitacaoServicoMedicaoItem");

            migrationBuilder.DropColumn(
                name: "CodigoCliente",
                table: "SolicitacaoServicoItem");

            migrationBuilder.DropColumn(
                name: "Descricao",
                table: "SolicitacaoServico");

            migrationBuilder.DropColumn(
                name: "ClassificacaoFiscal",
                table: "Produto");
        }
    }
}
