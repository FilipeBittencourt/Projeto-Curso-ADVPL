using Microsoft.EntityFrameworkCore.Migrations;

namespace Facile.BusinessPortal.StageArea.Model.Migrations
{
    public partial class _20201103_2 : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropPrimaryKey(
                name: "PK_RPV",
                table: "RPV");

            migrationBuilder.RenameTable(
                name: "RPV",
                newName: "Atendimento");

            migrationBuilder.AddPrimaryKey(
                name: "PK_Atendimento",
                table: "Atendimento",
                column: "ID");
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropPrimaryKey(
                name: "PK_Atendimento",
                table: "Atendimento");

            migrationBuilder.RenameTable(
                name: "Atendimento",
                newName: "RPV");

            migrationBuilder.AddPrimaryKey(
                name: "PK_RPV",
                table: "RPV",
                column: "ID");
        }
    }
}
