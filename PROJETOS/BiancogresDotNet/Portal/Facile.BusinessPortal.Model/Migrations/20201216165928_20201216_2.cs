using Microsoft.EntityFrameworkCore.Migrations;

namespace Facile.BusinessPortal.Model.Migrations
{
    public partial class _20201216_2 : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<long>(
                name: "ClasseValorID",
                table: "SetorAprovacao",
                nullable: false,
                defaultValue: 0L);

            migrationBuilder.CreateIndex(
                name: "IX_SetorAprovacao_ClasseValorID",
                table: "SetorAprovacao",
                column: "ClasseValorID");

            migrationBuilder.AddForeignKey(
                name: "FK_SetorAprovacao_ClasseValor_ClasseValorID",
                table: "SetorAprovacao",
                column: "ClasseValorID",
                principalTable: "ClasseValor",
                principalColumn: "ID",
                onDelete: ReferentialAction.Restrict);
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_SetorAprovacao_ClasseValor_ClasseValorID",
                table: "SetorAprovacao");

            migrationBuilder.DropIndex(
                name: "IX_SetorAprovacao_ClasseValorID",
                table: "SetorAprovacao");

            migrationBuilder.DropColumn(
                name: "ClasseValorID",
                table: "SetorAprovacao");
        }
    }
}
