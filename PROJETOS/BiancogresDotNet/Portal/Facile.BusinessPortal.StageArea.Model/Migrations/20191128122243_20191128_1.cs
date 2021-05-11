using Microsoft.EntityFrameworkCore.Migrations;

namespace Facile.BusinessPortal.StageArea.Model.Migrations
{
    public partial class _20191128_1 : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "NumeroControleParticipante",
                table: "AntecipacaoItem",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "NumeroDocumento",
                table: "AntecipacaoItem",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "Parcela",
                table: "AntecipacaoItem",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "Serie",
                table: "AntecipacaoItem",
                nullable: true);
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "NumeroControleParticipante",
                table: "AntecipacaoItem");

            migrationBuilder.DropColumn(
                name: "NumeroDocumento",
                table: "AntecipacaoItem");

            migrationBuilder.DropColumn(
                name: "Parcela",
                table: "AntecipacaoItem");

            migrationBuilder.DropColumn(
                name: "Serie",
                table: "AntecipacaoItem");
        }
    }
}
