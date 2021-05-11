using Microsoft.EntityFrameworkCore.Migrations;

namespace Facile.BusinessPortal.Model.Migrations
{
    public partial class _20201027_1 : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<long>(
                name: "UsuarioID",
                table: "RPV",
                nullable: true,
                defaultValue: null);

            migrationBuilder.CreateIndex(
                name: "IX_RPV_UsuarioID",
                table: "RPV",
                column: "UsuarioID");

            migrationBuilder.AddForeignKey(
                name: "FK_RPV_Usuario_UsuarioID",
                table: "RPV",
                column: "UsuarioID",
                principalTable: "Usuario",
                principalColumn: "ID",
                onDelete: ReferentialAction.Restrict);
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_RPV_Usuario_UsuarioID",
                table: "RPV");

            migrationBuilder.DropIndex(
                name: "IX_RPV_UsuarioID",
                table: "RPV");

            migrationBuilder.DropColumn(
                name: "UsuarioID",
                table: "RPV");
        }
    }
}
