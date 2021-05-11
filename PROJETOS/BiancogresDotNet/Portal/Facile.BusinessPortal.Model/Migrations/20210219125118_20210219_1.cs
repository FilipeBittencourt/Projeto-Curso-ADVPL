using Microsoft.EntityFrameworkCore.Migrations;

namespace Facile.BusinessPortal.Model.Migrations
{
    public partial class _20210219_1 : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<long>(
                name: "ArmazemID",
                table: "Produto",
                nullable: true);

            migrationBuilder.AlterColumn<long>(
                name: "FIDCID",
                table: "ContaBancaria",
                nullable: true,
                oldClrType: typeof(long));

            migrationBuilder.CreateIndex(
                name: "IX_Produto_ArmazemID",
                table: "Produto",
                column: "ArmazemID");

            migrationBuilder.AddForeignKey(
                name: "FK_Produto_Armazem_ArmazemID",
                table: "Produto",
                column: "ArmazemID",
                principalTable: "Armazem",
                principalColumn: "ID",
                onDelete: ReferentialAction.Restrict);
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Produto_Armazem_ArmazemID",
                table: "Produto");

            migrationBuilder.DropIndex(
                name: "IX_Produto_ArmazemID",
                table: "Produto");

            migrationBuilder.DropColumn(
                name: "ArmazemID",
                table: "Produto");

            migrationBuilder.AlterColumn<long>(
                name: "FIDCID",
                table: "ContaBancaria",
                nullable: false,
                oldClrType: typeof(long),
                oldNullable: true);
        }
    }
}
