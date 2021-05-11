using Microsoft.EntityFrameworkCore.Migrations;

namespace Facile.BusinessPortal.Model.Migrations
{
    public partial class _20200612_1 : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AlterColumn<long>(
                name: "PedidoCompraID",
                table: "NotaFiscalCompra",
                nullable: true,
                oldClrType: typeof(long));

            migrationBuilder.AddColumn<string>(
                name: "ChaveNFE",
                table: "NotaFiscalCompra",
                nullable: true);
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "ChaveNFE",
                table: "NotaFiscalCompra");

            migrationBuilder.AlterColumn<long>(
                name: "PedidoCompraID",
                table: "NotaFiscalCompra",
                nullable: false,
                oldClrType: typeof(long),
                oldNullable: true);
        }
    }
}
