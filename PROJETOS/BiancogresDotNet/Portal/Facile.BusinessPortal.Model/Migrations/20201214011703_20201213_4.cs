using Microsoft.EntityFrameworkCore.Migrations;

namespace Facile.BusinessPortal.Model.Migrations
{
    public partial class _20201213_4 : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "ContratoPedido",
                table: "SolicitacaoServicoItem",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "Item",
                table: "SolicitacaoServicoItem",
                nullable: true);
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "ContratoPedido",
                table: "SolicitacaoServicoItem");

            migrationBuilder.DropColumn(
                name: "Item",
                table: "SolicitacaoServicoItem");
        }
    }
}
