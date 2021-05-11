using Microsoft.EntityFrameworkCore.Migrations;

namespace Facile.BusinessPortal.Model.Migrations
{
    public partial class _2019093003 : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "EmailContato",
                table: "PerfilEmpresa",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "TelefoneContato",
                table: "PerfilEmpresa",
                nullable: true);
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "EmailContato",
                table: "PerfilEmpresa");

            migrationBuilder.DropColumn(
                name: "TelefoneContato",
                table: "PerfilEmpresa");
        }
    }
}
