using Microsoft.EntityFrameworkCore.Migrations;

namespace Facile.BusinessPortal.StageArea.Model.Migrations
{
    public partial class _20201103_1 : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "BairroReclamante",
                table: "RPV",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "CepReclamante",
                table: "RPV",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "CidadeReclamante",
                table: "RPV",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "ContatoReclamante",
                table: "RPV",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "EnderecoReclamante",
                table: "RPV",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "EstadoReclamante",
                table: "RPV",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "HorarioContatoReclamante",
                table: "RPV",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "NomeReclamante",
                table: "RPV",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "TelefoneReclamante",
                table: "RPV",
                nullable: true);
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "BairroReclamante",
                table: "RPV");

            migrationBuilder.DropColumn(
                name: "CepReclamante",
                table: "RPV");

            migrationBuilder.DropColumn(
                name: "CidadeReclamante",
                table: "RPV");

            migrationBuilder.DropColumn(
                name: "ContatoReclamante",
                table: "RPV");

            migrationBuilder.DropColumn(
                name: "EnderecoReclamante",
                table: "RPV");

            migrationBuilder.DropColumn(
                name: "EstadoReclamante",
                table: "RPV");

            migrationBuilder.DropColumn(
                name: "HorarioContatoReclamante",
                table: "RPV");

            migrationBuilder.DropColumn(
                name: "NomeReclamante",
                table: "RPV");

            migrationBuilder.DropColumn(
                name: "TelefoneReclamante",
                table: "RPV");
        }
    }
}
