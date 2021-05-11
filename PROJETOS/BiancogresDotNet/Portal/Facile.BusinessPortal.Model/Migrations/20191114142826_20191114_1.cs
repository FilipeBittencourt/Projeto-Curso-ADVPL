using Microsoft.EntityFrameworkCore.Migrations;

namespace Facile.BusinessPortal.Model.Migrations
{
    public partial class _20191114_1 : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<decimal>(
                name: "ValorTitulo",
                table: "AntecipacaoItem",
                nullable: false,
                defaultValue: 0m);

            migrationBuilder.AddColumn<decimal>(
                name: "ValorTituloAntecipado",
                table: "AntecipacaoItem",
                nullable: false,
                defaultValue: 0m);
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "ValorTitulo",
                table: "AntecipacaoItem");

            migrationBuilder.DropColumn(
                name: "ValorTituloAntecipado",
                table: "AntecipacaoItem");
        }
    }
}
