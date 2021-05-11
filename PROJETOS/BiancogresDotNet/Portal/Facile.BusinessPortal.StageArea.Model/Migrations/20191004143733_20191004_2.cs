using Microsoft.EntityFrameworkCore.Migrations;

namespace Facile.BusinessPortal.StageArea.Model.Migrations
{
    public partial class _20191004_2 : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "CodigoERP",
                table: "Fornecedor",
                nullable: true);

            migrationBuilder.AddColumn<bool>(
                name: "Habilitado",
                table: "Fornecedor",
                nullable: false,
                defaultValue: false);
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "CodigoERP",
                table: "Fornecedor");

            migrationBuilder.DropColumn(
                name: "Habilitado",
                table: "Fornecedor");
        }
    }
}
