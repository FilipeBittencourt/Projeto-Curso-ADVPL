using Microsoft.EntityFrameworkCore.Migrations;

namespace Facile.BusinessPortal.Model.Migrations
{
    public partial class _20201118_1 : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "Contato",
                table: "Fornecedor",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "Telefone",
                table: "Fornecedor",
                nullable: true);
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "Contato",
                table: "Fornecedor");

            migrationBuilder.DropColumn(
                name: "Telefone",
                table: "Fornecedor");
        }
    }
}
