using Microsoft.EntityFrameworkCore.Migrations;

namespace Facile.BusinessPortal.Model.Migrations
{
    public partial class _20200720_1 : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "Motorista",
                table: "NotaFiscalCompra");

            migrationBuilder.AddColumn<long>(
                name: "MotoristaID",
                table: "NotaFiscalCompra",
                nullable: true);

            migrationBuilder.CreateIndex(
                name: "IX_NotaFiscalCompra_MotoristaID",
                table: "NotaFiscalCompra",
                column: "MotoristaID");

            migrationBuilder.AddForeignKey(
                name: "FK_NotaFiscalCompra_Motorista_MotoristaID",
                table: "NotaFiscalCompra",
                column: "MotoristaID",
                principalTable: "Motorista",
                principalColumn: "ID",
                onDelete: ReferentialAction.Restrict);
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_NotaFiscalCompra_Motorista_MotoristaID",
                table: "NotaFiscalCompra");

            migrationBuilder.DropIndex(
                name: "IX_NotaFiscalCompra_MotoristaID",
                table: "NotaFiscalCompra");

            migrationBuilder.DropColumn(
                name: "MotoristaID",
                table: "NotaFiscalCompra");

            migrationBuilder.AddColumn<string>(
                name: "Motorista",
                table: "NotaFiscalCompra",
                nullable: true);
        }
    }
}
