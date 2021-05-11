using Microsoft.EntityFrameworkCore.Migrations;

namespace Facile.BusinessPortal.StageArea.Model.Migrations
{
    public partial class _20200609_2 : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.RenameColumn(
                name: "NumeroPedidoItem",
                table: "NotaFiscalCompra",
                newName: "PedidoItem");

            migrationBuilder.RenameColumn(
                name: "NumeroPedido",
                table: "NotaFiscalCompra",
                newName: "PedidoNumero");
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.RenameColumn(
                name: "PedidoNumero",
                table: "NotaFiscalCompra",
                newName: "NumeroPedidoItem");

            migrationBuilder.RenameColumn(
                name: "PedidoItem",
                table: "NotaFiscalCompra",
                newName: "NumeroPedido");
        }
    }
}
