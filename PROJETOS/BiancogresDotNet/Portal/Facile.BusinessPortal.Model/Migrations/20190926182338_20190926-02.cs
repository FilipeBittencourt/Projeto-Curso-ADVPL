using Microsoft.EntityFrameworkCore.Migrations;

namespace Facile.BusinessPortal.Model.Migrations
{
    public partial class _2019092602 : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "EmailHomologacao",
                table: "Empresa",
                nullable: true);

            migrationBuilder.AddColumn<bool>(
                name: "Homologacao",
                table: "Empresa",
                nullable: false,
                defaultValue: false);
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "EmailHomologacao",
                table: "Empresa");

            migrationBuilder.DropColumn(
                name: "Homologacao",
                table: "Empresa");
        }
    }
}
