using Microsoft.EntityFrameworkCore.Migrations;

namespace Facile.BusinessPortal.Model.Migrations
{
    public partial class _20201211_2 : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "Cotacao",
                table: "SolicitacaoServicoFornecedor",
                nullable: true);

            migrationBuilder.AddColumn<bool>(
                name: "Vencedor",
                table: "SolicitacaoServicoFornecedor",
                nullable: false,
                defaultValue: false);
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "Cotacao",
                table: "SolicitacaoServicoFornecedor");

            migrationBuilder.DropColumn(
                name: "Vencedor",
                table: "SolicitacaoServicoFornecedor");
        }
    }
}
