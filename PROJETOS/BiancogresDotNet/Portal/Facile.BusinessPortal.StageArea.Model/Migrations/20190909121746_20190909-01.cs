using Microsoft.EntityFrameworkCore.Migrations;

namespace Facile.BusinessPortal.StageArea.Model.Migrations
{
    public partial class _2019090901 : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "ChaveUnica",
                table: "Sacado",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "ChaveUnica",
                table: "LogIntegracao",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "ChaveUnica",
                table: "Boleto",
                nullable: true);
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "ChaveUnica",
                table: "Sacado");

            migrationBuilder.DropColumn(
                name: "ChaveUnica",
                table: "LogIntegracao");

            migrationBuilder.DropColumn(
                name: "ChaveUnica",
                table: "Boleto");
        }
    }
}
