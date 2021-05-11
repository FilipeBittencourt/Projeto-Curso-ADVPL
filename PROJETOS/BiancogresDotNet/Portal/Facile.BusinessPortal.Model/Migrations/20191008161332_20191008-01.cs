using Microsoft.EntityFrameworkCore.Migrations;

namespace Facile.BusinessPortal.Model.Migrations
{
    public partial class _2019100801 : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "Site_Root_Path",
                table: "PerfilEmpresa",
                nullable: true);
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {          
            migrationBuilder.DropColumn(
                name: "Site_Root_Path",
                table: "PerfilEmpresa");
        }
    }
}
