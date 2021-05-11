using Microsoft.EntityFrameworkCore.Migrations;

namespace Facile.BusinessPortal.Model.Migrations
{
    public partial class _2019101401 : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "CodigoERP",
                table: "Sacado",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "CodigoERP",
                table: "Fornecedor",
                nullable: true);
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "CodigoERP",
                table: "Sacado");

            migrationBuilder.DropColumn(
                name: "CodigoERP",
                table: "Fornecedor");
        }
    }
}
