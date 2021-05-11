using Microsoft.EntityFrameworkCore.Migrations;

namespace Facile.BusinessPortal.StageArea.Model.Migrations
{
    public partial class _20201109_2 : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<long>(
                name: "AtendimentoIDPortal",
                table: "AtendimentoMedicao",
                nullable: false,
                defaultValue: 0L);

            migrationBuilder.AddColumn<long>(
                name: "IDPortal",
                table: "AtendimentoMedicao",
                nullable: false,
                defaultValue: 0L);
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "AtendimentoIDPortal",
                table: "AtendimentoMedicao");

            migrationBuilder.DropColumn(
                name: "IDPortal",
                table: "AtendimentoMedicao");
        }
    }
}
