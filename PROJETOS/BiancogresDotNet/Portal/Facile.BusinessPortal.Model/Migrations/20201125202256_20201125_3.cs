using Microsoft.EntityFrameworkCore.Migrations;

namespace Facile.BusinessPortal.Model.Migrations
{
    public partial class _20201125_3 : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<long>(
                name: "ClasseValorID",
                table: "TAG",
                nullable: false,
                defaultValue: 0L);

            migrationBuilder.CreateIndex(
                name: "IX_TAG_ClasseValorID",
                table: "TAG",
                column: "ClasseValorID");

            migrationBuilder.AddForeignKey(
                name: "FK_TAG_ClasseValor_ClasseValorID",
                table: "TAG",
                column: "ClasseValorID",
                principalTable: "ClasseValor",
                principalColumn: "ID",
                onDelete: ReferentialAction.Restrict);
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_TAG_ClasseValor_ClasseValorID",
                table: "TAG");

            migrationBuilder.DropIndex(
                name: "IX_TAG_ClasseValorID",
                table: "TAG");

            migrationBuilder.DropColumn(
                name: "ClasseValorID",
                table: "TAG");
        }
    }
}
