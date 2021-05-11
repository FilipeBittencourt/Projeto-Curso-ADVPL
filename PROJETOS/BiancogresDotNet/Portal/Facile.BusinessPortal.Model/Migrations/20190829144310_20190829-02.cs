using Microsoft.EntityFrameworkCore.Migrations;

namespace Facile.BusinessPortal.Model.Migrations
{
    public partial class _2019082902 : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "Complemento",
                table: "Sacado",
                nullable: true);

            migrationBuilder.AddColumn<bool>(
                name: "MestreGrupo",
                table: "Sacado",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<string>(
                name: "Numero",
                table: "Sacado",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "Complemento",
                table: "Fornecedor",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "Numero",
                table: "Fornecedor",
                nullable: true);
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "Complemento",
                table: "Sacado");

            migrationBuilder.DropColumn(
                name: "MestreGrupo",
                table: "Sacado");

            migrationBuilder.DropColumn(
                name: "Numero",
                table: "Sacado");

            migrationBuilder.DropColumn(
                name: "Complemento",
                table: "Fornecedor");

            migrationBuilder.DropColumn(
                name: "Numero",
                table: "Fornecedor");
        }
    }
}
