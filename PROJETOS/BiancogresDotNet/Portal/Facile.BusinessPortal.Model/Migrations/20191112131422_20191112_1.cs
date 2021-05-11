using Microsoft.EntityFrameworkCore.Migrations;

namespace Facile.BusinessPortal.Model.Migrations
{
    public partial class _20191112_1 : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "Tipo",
                table: "Mail",
                nullable: false,
                defaultValue: 0);
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "Tipo",
                table: "Mail");
        }
    }
}
