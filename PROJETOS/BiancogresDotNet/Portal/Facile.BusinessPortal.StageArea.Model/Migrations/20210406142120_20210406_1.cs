using Microsoft.EntityFrameworkCore.Migrations;

namespace Facile.BusinessPortal.StageArea.Model.Migrations
{
    public partial class _20210406_1 : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "TipoAntecipacao",
                table: "Fornecedor");

            migrationBuilder.AddColumn<int>(
                name: "TipoDocumento",
                table: "TituloPagar",
                nullable: false,
                defaultValue: 0);

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

            migrationBuilder.AddColumn<string>(
                name: "RazaoSocial",
                table: "Fornecedor",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "Tipo",
                table: "Antecipacao",
                nullable: false,
                defaultValue: 0);
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
                name: "RazaoSocial",
                table: "Fornecedor");

            migrationBuilder.DropColumn(
                name: "Tipo",
                table: "Antecipacao");

            migrationBuilder.AddColumn<int>(
                name: "TipoAntecipacao",
                table: "Fornecedor",
                nullable: false,
                defaultValue: 0);
        }
    }
}
