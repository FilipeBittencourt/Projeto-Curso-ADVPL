using Microsoft.EntityFrameworkCore.Migrations;

namespace Facile.BusinessPortal.Model.Migrations
{
    public partial class _20201125_1 : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<long>(
                name: "ClasseValorID",
                table: "Driver",
                nullable: false,
                defaultValue: 0L);

            migrationBuilder.CreateIndex(
                name: "IX_Driver_ClasseValorID",
                table: "Driver",
                column: "ClasseValorID");

            migrationBuilder.AddForeignKey(
                name: "FK_Driver_ClasseValor_ClasseValorID",
                table: "Driver",
                column: "ClasseValorID",
                principalTable: "ClasseValor",
                principalColumn: "ID",
                onDelete: ReferentialAction.Restrict);
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Driver_ClasseValor_ClasseValorID",
                table: "Driver");

            migrationBuilder.DropIndex(
                name: "IX_Driver_ClasseValorID",
                table: "Driver");

            migrationBuilder.DropColumn(
                name: "ClasseValorID",
                table: "Driver");
        }
    }
}
