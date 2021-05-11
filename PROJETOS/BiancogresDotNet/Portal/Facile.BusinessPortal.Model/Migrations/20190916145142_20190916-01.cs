using Microsoft.EntityFrameworkCore.Migrations;

namespace Facile.BusinessPortal.Model.Migrations
{
    public partial class _2019091601 : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "Complemento",
                table: "Cedente",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "Numero",
                table: "Cedente",
                nullable: true);
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "Complemento",
                table: "Cedente");

            migrationBuilder.DropColumn(
                name: "Numero",
                table: "Cedente");
        }
    }
}
