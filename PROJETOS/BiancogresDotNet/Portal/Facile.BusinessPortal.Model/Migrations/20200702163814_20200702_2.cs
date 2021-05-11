using Microsoft.EntityFrameworkCore.Migrations;

namespace Facile.BusinessPortal.Model.Migrations
{
    public partial class _20200702_2 : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<bool>(
                name: "EntregaAutorizada",
                table: "NotaFiscalCompra",
                nullable: false,
                defaultValue: false);
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "EntregaAutorizada",
                table: "NotaFiscalCompra");
        }
    }
}
