using Microsoft.EntityFrameworkCore.Migrations;

namespace Facile.BusinessPortal.Model.Migrations
{
    public partial class _20210317_1 : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "Cotacao",
                table: "SolicitacaoServicoItem",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "CotacaoItem",
                table: "SolicitacaoServicoItem",
                nullable: true);
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "Cotacao",
                table: "SolicitacaoServicoItem");

            migrationBuilder.DropColumn(
                name: "CotacaoItem",
                table: "SolicitacaoServicoItem");
        }
    }
}
