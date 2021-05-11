using Microsoft.EntityFrameworkCore.Migrations;

namespace Facile.BusinessPortal.StageArea.Model.Migrations
{
    public partial class _2019090402 : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.RenameColumn(
                name: "Email",
                table: "Sacado",
                newName: "EmailWorkflow");

            migrationBuilder.AddColumn<string>(
                name: "EmailUsuario",
                table: "Sacado",
                nullable: true);
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "EmailUsuario",
                table: "Sacado");

            migrationBuilder.RenameColumn(
                name: "EmailWorkflow",
                table: "Sacado",
                newName: "Email");
        }
    }
}
