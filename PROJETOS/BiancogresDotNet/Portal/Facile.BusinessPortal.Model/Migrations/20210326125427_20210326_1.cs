using Microsoft.EntityFrameworkCore.Migrations;

namespace Facile.BusinessPortal.Model.Migrations
{
    public partial class _20210326_1 : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "TipoDocumento",
                table: "TituloPagar",
                nullable: true);

            migrationBuilder.AddColumn<bool>(
                name: "AntecipaServico",
                table: "Fornecedor",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<bool>(
                name: "FIDCAtivo",
                table: "Fornecedor",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<int>(
                name: "Tipo",
                table: "Antecipacao",
                nullable: true);
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "TipoDocumento",
                table: "TituloPagar");

            migrationBuilder.DropColumn(
                name: "AntecipaServico",
                table: "Fornecedor");

            migrationBuilder.DropColumn(
                name: "FIDCAtivo",
                table: "Fornecedor");

            migrationBuilder.DropColumn(
                name: "Tipo",
                table: "Antecipacao");
        }
    }
}
