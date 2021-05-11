using Microsoft.EntityFrameworkCore.Migrations;

namespace Facile.BusinessPortal.Model.Migrations
{
    public partial class _20201103_2 : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "BairroReclamante",
                table: "Atendimento",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "CepReclamante",
                table: "Atendimento",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "CidadeReclamante",
                table: "Atendimento",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "ContatoReclamante",
                table: "Atendimento",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "EnderecoReclamante",
                table: "Atendimento",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "EstadoReclamante",
                table: "Atendimento",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "HorarioContatoReclamante",
                table: "Atendimento",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "NomeReclamante",
                table: "Atendimento",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "TelefoneReclamante",
                table: "Atendimento",
                nullable: true);
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "BairroReclamante",
                table: "Atendimento");

            migrationBuilder.DropColumn(
                name: "CepReclamante",
                table: "Atendimento");

            migrationBuilder.DropColumn(
                name: "CidadeReclamante",
                table: "Atendimento");

            migrationBuilder.DropColumn(
                name: "ContatoReclamante",
                table: "Atendimento");

            migrationBuilder.DropColumn(
                name: "EnderecoReclamante",
                table: "Atendimento");

            migrationBuilder.DropColumn(
                name: "EstadoReclamante",
                table: "Atendimento");

            migrationBuilder.DropColumn(
                name: "HorarioContatoReclamante",
                table: "Atendimento");

            migrationBuilder.DropColumn(
                name: "NomeReclamante",
                table: "Atendimento");

            migrationBuilder.DropColumn(
                name: "TelefoneReclamante",
                table: "Atendimento");
        }
    }
}
