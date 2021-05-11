using Microsoft.EntityFrameworkCore.Migrations;

namespace Facile.BusinessPortal.Model.Migrations
{
    public partial class _20191112_2 : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "Tipo",
                table: "Mail");

            migrationBuilder.AddColumn<int>(
                name: "EmailModulo",
                table: "Mail",
                nullable: false,
                defaultValue: 0);
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "EmailModulo",
                table: "Mail");

            migrationBuilder.AddColumn<int>(
                name: "Tipo",
                table: "Mail",
                nullable: false,
                defaultValue: 0);
        }
    }
}
